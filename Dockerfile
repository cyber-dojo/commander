FROM  cyberdojo/docker-base
LABEL maintainer=jon@jaggersoft.com

RUN export RACK_ENV='production'

# - - - - - - - - - - - - - - - - - - - - - -
# Install glibc on Alpine (required by docker-compose) from
# https://github.com/sgerrand/alpine-pkg-glibc
# See also https://github.com/gliderlabs/docker-alpine/issues/11
# - - - - - - - - - - - - - - - - - - - - - -

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates curl && \
    GLIBC_VERSION='2.28-r0' && \
    curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -Lo glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk && \
    curl -Lo glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk && \
    apk update && \
    apk add glibc.apk glibc-bin.apk && \
    rm -rf /var/cache/apk/* && \
    rm glibc.apk glibc-bin.apk && \
    apk del .deps

# - - - - - - - - - - - - - - - - - - - - - -
# install docker-compose
# https://docs.docker.com/compose/install/
# https://github.com/wernight/docker-compose/blob/master/Dockerfile
# - - - - - - - - - - - - - - - - - - - - - -

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates curl && \
    DOCKER_COMPOSE_URL=https://github.com/docker/compose/releases/download/1.22.0/docker-compose-Linux-x86_64 && \
    curl -Lo /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    docker-compose version && \
    apk del .deps

# - - - - - - - - - - - - - - - - - - - - - -
# install commander source
# - - - - - - - - - - - - - - - - - - - - - -

RUN adduser -D -H -u 19661 cyber-dojo

ARG HOME_DIR=/app
COPY . ${HOME_DIR}
WORKDIR ${HOME_DIR}

# - - - - - - - - - - - - - - - - - - - - - -
# make sure default .env files can be overwritten
# - - - - - - - - - - - - - - - - - - - - - -

ARG CYBER_DOJO_ENV_ROOT=/tmp/app
RUN mkdir ${CYBER_DOJO_ENV_ROOT} \
  && cp -r ${HOME_DIR}/defaults.env/* ${CYBER_DOJO_ENV_ROOT} \
  && chmod -R a+w ${CYBER_DOJO_ENV_ROOT}
