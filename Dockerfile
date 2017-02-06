FROM debian:wheezy

MAINTAINER Bruno Binet <bruno.binet@helioslite.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C

RUN echo "deb http://debian.saltstack.com/debian wheezy-saltstack-2015-05 main" > /etc/apt/sources.list.d/salt.list
ADD debian-salt-team-joehealy.gpg.key /tmp/debian-salt-team-joehealy.gpg.key
RUN apt-key add /tmp/debian-salt-team-joehealy.gpg.key && \
  rm /tmp/debian-salt-team-joehealy.gpg.key

ENV SALT_VERSION 2015.5.3+ds-1~bpo70+2
RUN apt-get update && apt-get install -yq --no-install-recommends \
  salt-minion=${SALT_VERSION} vim ssh less net-tools procps lsb-release ifupdown && \
  rm -rf /var/lib/apt/lists/* && apt-get clean

ADD run.sh /run.sh
RUN chmod a+x /run.sh

RUN rm /usr/sbin/policy-rc.d

ENV SALT_CONFIG /etc/salt
ENV BEFORE_EXEC_SCRIPT ${SALT_CONFIG}/before-exec.sh
ENV EXEC_CMD /sbin/init 2

CMD ["/run.sh"]
