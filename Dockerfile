FROM cyberdojo/user-base
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1. install tini (for pid 1 zombie reaping)
# https://github.com/krallin/tini
# https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/

USER root
RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini
ENTRYPOINT ["/sbin/tini", "--"]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2. install docker-client
# Launching a docker app (that itself uses docker) is
# different on different host OS's... eg
#
# OSX 10.10 (Yosemite)
# --------------------
# The Docker-Quickstart-Terminal uses docker-machine to forward
# docker commands to a boot2docker VM called default.
# In this VM the docker binary lives at /usr/local/bin/
#
#    -v /usr/local/bin/docker:/usr/local/bin/docker
#
# Ubuntu 14.04 (Trusty)
# ---------------------
# The docker binary lives at /usr/bin and has a dependency on apparmor 1.1
#
#    -v /usr/bin/docker:/usr/bin/docker
#    -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0 ...
#
# Debian 8 (Jessie)
# -----------------
# The docker binary lives at /usr/bin and has a dependency to apparmor 1.2
#
#    -v /usr/bin/docker:/usr/bin/docker
#    -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.2.0 ...
#
# I originally used docker-compose extension files specific to each OS.
# I now install the docker client _inside_ the image.
# This means there is no host<-container uid dependency.
# But there is a host<-container docker version dependency.
#
# docker 1.11.0+ now relies on four binaries
# See https://github.com/docker/docker/wiki/Engine-1.11.0
# See https://docs.docker.com/engine/installation/binaries/
#
# After this, the cyber-dojo user can do
# $ sudo -u docker-runner sudo docker ...
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARG  DOCKER_VERSION
USER root
RUN  apk update \
  && apk add --no-cache curl \
  && curl -OL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz \
  && tar -xvzf docker-${DOCKER_VERSION}.tgz \
  && mv docker/* /usr/bin/ \
  && rmdir /docker \
  && rm /docker-${DOCKER_VERSION}.tgz \
  && apk del curl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 3. ensure cyber-dojo user can sudo to docker-runner user
# which can run docker and docker-compose
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARG  DOCKER_BINARY=/usr/bin/docker
ARG  DOCKER_COMPOSE_BINARY=/usr/bin/docker-compose
ARG  NEEDS_DOCKER_SUDO=cyber-dojo
ARG  GETS_DOCKER_SUDO=docker-runner
ARG  SUDO_FILE=/etc/sudoers.d/${GETS_DOCKER_SUDO}
USER root
# -D=no password, -H=no home directory
RUN  adduser -D -H ${GETS_DOCKER_SUDO}
# there is no sudo command in Alpine
RUN  apk --update add sudo
# cyber-dojo, on all hosts, can sudo -u docker-runner, without a password
RUN  echo "${NEEDS_DOCKER_SUDO} ALL=(${GETS_DOCKER_SUDO}) NOPASSWD: ALL"   >  ${SUDO_FILE}
# docker-runner, on all hosts, without a password, can sudo /usr/bin/docker
RUN  echo "${GETS_DOCKER_SUDO} ALL=NOPASSWD: ${DOCKER_BINARY} *"         >>  ${SUDO_FILE}
# docker-runner, on all hosts, without a password, can sudo /usr/bin/docker-compose
RUN  echo "${GETS_DOCKER_SUDO} ALL=NOPASSWD: ${DOCKER_COMPOSE_BINARY} *" >>  ${SUDO_FILE}

# - - - - - - - - - - - - - - - - - - - - - -
# 4. install docker-compose
# https://github.com/marcosnils/compose/blob/master/Dockerfile.run
# After this, the cyber-dojo user can do
# $ sudo -u docker-runner sudo docker-compose ...

ARG  DOCKER_COMPOSE_VERSION
USER root
RUN  apk update \
  && apk add --no-cache curl openssl ca-certificates \
  && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > ${DOCKER_COMPOSE_BINARY} \
  && chmod +x ${DOCKER_COMPOSE_BINARY} \
  && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk \
  && apk add --no-cache glibc-2.23-r3.apk && rm glibc-2.23-r3.apk \
  && ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ \
  && ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib \
  && apk del curl

# - - - - - - - - - - - - - - - - - - - - - -
# 5. install ruby

USER root
RUN  apk update && apk add ruby ruby-irb ruby-io-console ruby-bigdecimal tzdata bash

# - - - - - - - - - - - - - - - - - - - - - -
# 6. install json gem

RUN  mkdir /app
COPY Gemfile /app
RUN  apk --update \
        add --virtual build-dependencies \
          build-base \
          ruby-dev \
          openssl-dev \
          postgresql-dev \
          libc-dev \
          linux-headers \
        && gem install bundler --no-ri --no-rdoc \
        && cd /app \
        && bundle install \
        && apk del build-dependencies

# - - - - - - - - - - - - - - - - - - - - - -
# 5. install commander

COPY cyber-dojo.sh          /app
COPY cyber-dojo.rb          /app
COPY docker-compose.yml     /app
COPY start_point_check.rb   /app
COPY start_point_inspect.rb /app
COPY start_point_pull.rb    /app
RUN  chown -R cyber-dojo:cyber-dojo /app
WORKDIR /app


