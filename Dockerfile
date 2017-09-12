FROM  cyberdojo/docker
LABEL maintainer=jon@jaggersoft.com

ARG  DOCKER_COMPOSE_VERSION

USER root

# - - - - - - - - - - - - - - - - - - - - - -
# install docker-compose

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
