FROM cyberdojo/docker-base:19116ed
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - - - - - - -
# https://github.com/wernight/docker-compose/blob/master/Dockerfile
# - - - - - - - - - - - - - - - - - - - - - -

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    VERSION=2.35-r0 && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${VERSION}/glibc-${VERSION}.apk && \
    apk add --force-overwrite glibc-${VERSION}.apk && \
    rm glibc-${VERSION}.apk && \
    apk del --purge .deps

# Required for docker-compose to find zlib.
ENV LD_LIBRARY_PATH=/lib:/usr/lib

RUN VERSION=v2.16.0 && \
    DOCKER_COMPOSE_URL=https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-linux-x86_64 && \
    wget -q -O /usr/local/bin/docker-compose ${DOCKER_COMPOSE_URL} && \
    chmod a+rx /usr/local/bin/docker-compose

# - - - - - - - - - - - - - - - - - - - - - -
# install commander source
# - - - - - - - - - - - - - - - - - - - - - -

RUN adduser -D -H -u 19661 cyber-dojo

ARG HOME_DIR=/app
COPY . ${HOME_DIR}
WORKDIR ${HOME_DIR}

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}
