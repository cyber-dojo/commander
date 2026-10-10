# Pinned to the base's multi-platform index, so the same pin serves the
# linux/amd64 and linux/arm64 builds.
FROM docker:29.7.2-dind-alpine3.24@sha256:12e683a161823b2a839aeea999b9d960e6e1f9a97b1679ad6b441982e2d9cf07
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
# install commander source
# - - - - - - - - - - - - - - - - - - - - - -

RUN adduser -D -H -u 19661 cyber-dojo

WORKDIR /app
COPY /app .
