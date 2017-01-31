FROM debian:jessie

MAINTAINER Bruno Binet <bruno.binet@helioslite.com>

ENV DEBIAN_FRONTEND noninteractive
ENV SALT_VERSION 2016.11
ENV REFRESHED_AT 2017-01-31
ENV LC_ALL C

RUN echo "deb http://repo.saltstack.com/apt/debian/8/amd64/${SALT_VERSION} jessie main" > /etc/apt/sources.list.d/salt.list

ADD https://repo.saltstack.com/apt/debian/8/amd64/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub /tmp/SALTSTACK-GPG-KEY.pub
RUN echo "9e0d77c16ba1fe57dfd7f1c5c2130438  /tmp/SALTSTACK-GPG-KEY.pub" | md5sum --check
RUN apt-key add /tmp/SALTSTACK-GPG-KEY.pub

RUN apt-get update && apt-get install -yq --no-install-recommends \
  salt-minion dbus vim ssh less net-tools procps lsb-release ifupdown

ADD dbus.service /etc/systemd/system/dbus.service
ADD run.sh /run.sh
RUN chmod a+x /run.sh

RUN rm /usr/sbin/policy-rc.d

VOLUME /sys/fs/cgroup

ENV SALT_CONFIG /etc/salt
ENV BEFORE_EXEC_SCRIPT ${SALT_CONFIG}/before-exec.sh
ENV EXEC_CMD /lib/systemd/systemd systemd.unit=multi-user.target

CMD ["/run.sh"]
