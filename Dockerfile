FROM  alpine:latest
LABEL maintainer=jon@jaggersoft.com

USER root
RUN adduser -D -H -u 19661 cyber-dojo

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install ruby
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    openssl ca-certificates \
    ruby ruby-io-console ruby-dev ruby-irb ruby-bundler ruby-bigdecimal \
    bash tzdata

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install ruby gems
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN echo 'gem: --no-document' > ~/.gemrc
COPY Gemfile /app/
WORKDIR /app

RUN apk --update add --virtual build-dependencies build-base \
  && bundle install && gem clean \
  && apk del build-dependencies \
  && rm -vrf /var/cache/apk/*

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install tini (for pid 1 zombie reaping)
# https://github.com/krallin/tini

RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install docker-client
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
# In practice, the features of docker I use are not exotic and
# I can (and do) ignore this version dependency.
#
# docker 1.11.0+ now relies on four binaries
# See https://github.com/docker/docker/wiki/Engine-1.11.0
# See https://docs.docker.com/engine/installation/binaries/
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARG DOCKER_ENGINE_VERSION

RUN apk --update add curl \
  && curl -OL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_ENGINE_VERSION}.tgz \
  && tar -xvzf docker-${DOCKER_ENGINE_VERSION}.tgz \
  && mv docker/* /usr/bin/ \
  && rmdir docker \
  && rm docker-${DOCKER_ENGINE_VERSION}.tgz \
  && apk del curl

# - - - - - - - - - - - - - - - - - - - - - -
# install docker-compose
# - - - - - - - - - - - - - - - - - - - - - -

ARG DOCKER_COMPOSE_VERSION
ARG DOCKER_COMPOSE_BINARY=/usr/bin/docker-compose

RUN apk add --no-cache curl openssl ca-certificates \
 && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > ${DOCKER_COMPOSE_BINARY} \
 && chmod +x ${DOCKER_COMPOSE_BINARY} \
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk \
 && apk add --no-cache glibc-2.23-r3.apk && rm glibc-2.23-r3.apk \
 && ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ \
 && ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib \
 && apk del curl

# - - - - - - - - - - - - - - - - - - - - - -
# [start-point create NAME --git=...] requires git clone
RUN apk add --update git

# [start-point create NAME --list=...] requires curl
RUN apk add --update curl

# - - - - - - - - - - - - - - - - - - - - - -
# install commander source

ARG HOME_DIR=/app
COPY . ${HOME_DIR}
WORKDIR ${HOME_DIR}

ENTRYPOINT [ "/sbin/tini", "--" ]
