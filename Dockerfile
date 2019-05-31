FROM  cyberdojo/docker-base
LABEL maintainer=jon@jaggersoft.com

RUN export RACK_ENV='production'

# - - - - - - - - - - - - - - - - - - - - - -
# https://github.com/wernight/docker-compose/blob/master/Dockerfile
# - - - - - - - - - - - - - - - - - - - - - -

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk && \
    apk add glibc-2.29-r0.apk && \
    rm glibc-2.29-r0.apk && \
    apk del --purge .deps

# Required for docker-compose to find zlib.
ENV LD_LIBRARY_PATH=/lib:/usr/lib

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    apk add --no-cache zlib libgcc && \
    DOCKER_COMPOSE_URL=https://github.com$(wget -q -O- https://github.com/docker/compose/releases/latest \
        | grep -Eo 'href="[^"]+docker-compose-Linux-x86_64' \
        | sed 's/^href="//' \
        | head -n1) && \
    wget -q -O /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    apk del --purge .deps && \
    docker-compose version

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
