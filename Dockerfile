FROM cyberdojo/docker-base:623a63d@sha256:94fa06fcd6d728b03943344b4cd0c237efa864c3d91cb29a4b5544e5181d0999
# The FROM statement above is typically set via an automated pull-request from the docker-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

# - - - - - - - - - - - - - - - - - - - - - -
# https://github.com/wernight/docker-compose/blob/master/Dockerfile
# - - - - - - - - - - - - - - - - - - - - - -

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    VERSION=2.35-r1 && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${VERSION}/glibc-${VERSION}.apk && \
    apk add --force-overwrite glibc-${VERSION}.apk && \
    rm glibc-${VERSION}.apk && \
    apk del --purge .deps

# - - - - - - - - - - - - - - - - - - - - - -
# install commander source
# - - - - - - - - - - - - - - - - - - - - - -

RUN adduser -D -H -u 19661 cyber-dojo

WORKDIR /app
COPY /app .
