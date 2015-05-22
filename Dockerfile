FROM debian:jessie

MAINTAINER Bruno Binet <bruno.binet@helioslite.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C

RUN echo "deb http://debian.saltstack.com/debian jessie-saltstack-2015-05 main" > /etc/apt/sources.list.d/salt.list
ADD debian-salt-team-joehealy.gpg.key /tmp/debian-salt-team-joehealy.gpg.key
RUN apt-key add /tmp/debian-salt-team-joehealy.gpg.key && \
  rm /tmp/debian-salt-team-joehealy.gpg.key

ENV SALT_VERSION 2015.5.0+ds-1~bpo8+1
RUN apt-get update && apt-get install -yq --no-install-recommends \
  salt-minion=${SALT_VERSION} vim ssh net-tools procps && \
  rm -rf /var/lib/apt/lists/* && apt-get clean

RUN rm /usr/sbin/policy-rc.d

VOLUME /etc/salt
VOLUME /sys/fs/cgroup

CMD ["/lib/systemd/systemd", "systemd.unit=multi-user.target"]
