# The base is multi-arch but this image is not: the glibc apk fetched below is
# x86_64 only, so the platform is pinned rather than left to the builder's host.
FROM --platform=linux/amd64 docker:29.7.2-dind-alpine3.24@sha256:12e683a161823b2a839aeea999b9d960e6e1f9a97b1679ad6b441982e2d9cf07
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - -
# The base supplies docker, its compose and buildx plugins, git and tar.
# It has no ruby and no bash, which is what these two add:
# - bash runs the scripts under app/sh
# - ruby runs app/cyber-dojo.rb and app/lib. Alpine's ruby package carries the
#   json, tempfile and date it requires, so there is no Gemfile to bundle.
# - - - - - - - - - - - - - - - -

RUN apk --update --upgrade --no-cache add \
    bash \
    ruby \
  && rm -vrf /var/cache/apk/*

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
