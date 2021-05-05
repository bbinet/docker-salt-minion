FROM resin/amd64-debian:buster

MAINTAINER Bruno Binet <bruno.binet@helioslite.com>

# enable container init system.
ENV container docker
ENV INITSYSTEM on
ENV UDEV on
ENV DEBIAN_FRONTEND noninteractive

ENV SALT_VERSION 3003
#ENV REFRESHED_AT 2019-03-07

# make the "en_US.UTF-8" locale so supervisor will be utf-8 enabled by default
# see: https://github.com/docker-library/postgres/blob/master/13/Dockerfile#L47-L57
RUN set -eux; \
       if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
# if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
               grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
               sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
               ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
       fi; \
       if [ -f /etc/dpkg/dpkg.cfg.d/01_nodoc ]; then \
               grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/01_nodoc; \
               sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/01_nodoc; \
               ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/01_nodoc; \
       fi; \
       apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
       localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/debian/10/amd64/${SALT_VERSION}/salt-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltproject.io/py3/debian/10/amd64/${SALT_VERSION} buster main" | sudo tee /etc/apt/sources.list.d/salt.list

RUN apt-get update && apt-get install -yq --no-install-recommends \
    dbus vim ssh less net-tools procps lsb-release ifupdown \
    make git wget python2.7 python-apt apt-transport-https \
    python-concurrent.futures dnsmasq wireless-tools gnupg salt-minion \
    && rm -rf /var/lib/apt/lists/*

RUN cp /lib/systemd/system/dbus.service /etc/systemd/system/; \
    sed -i 's/OOMScoreAdjust=.*//' /etc/systemd/system/dbus.service

COPY override.conf /etc/systemd/system/salt-minion.service.d/override.conf
COPY pre-salt-minion.sh /usr/local/bin/pre-salt-minion.sh

VOLUME /sys/fs/cgroup

ENV BEFORE_EXEC_SCRIPT /etc/salt/before-exec.sh

CMD ["/bin/date"]
