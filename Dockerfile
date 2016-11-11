FROM alpine:3.4
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ARG  DOCKER_VERSION
ARG  DOCKER_COMPOSE_VERSION

USER root

# - - - - - - - - - - - - - - - - - - - - - -
# 1. install docker

RUN apk update \
 && apk add --no-cache curl \
 && curl -OL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz \
 && tar -xvzf docker-${DOCKER_VERSION}.tgz \
 && mv docker/* /usr/bin/ \
 && rmdir /docker \
 && rm /docker-${DOCKER_VERSION}.tgz

# - - - - - - - - - - - - - - - - - - - - - -
# 2. install docker-compose
# https://github.com/marcosnils/compose/blob/master/Dockerfile.run

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
# 3. [start-point create NAME --git=URL] requires git clone
# [start-point create ...] requires cyber-dojo user to own created volume
# -D=no password, -H=no home directory
RUN apk add git \
 && adduser -D -H -u 19661 cyber-dojo

# - - - - - - - - - - - - - - - - - - - - - -
# 4. install ruby and gems

RUN apk add ruby ruby-irb ruby-io-console ruby-bigdecimal ruby-dev ruby-bundler tzdata
RUN echo 'gem: --no-document' > ~/.gemrc
COPY Gemfile ${app_dir}/
RUN apk --update add --virtual build-dependencies build-base \
  && bundle install && gem clean \
  && apk del build-dependencies \
  && rm -vrf /var/cache/apk/*

# - - - - - - - - - - - - - - - - - - - - - -
# 5. install commander source

ARG HOME_DIR=/app
RUN mkdir ${HOME_DIR}
COPY . ${HOME_DIR}
WORKDIR ${HOME_DIR}
