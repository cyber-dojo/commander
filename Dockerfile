FROM  docker:latest
LABEL maintainer=jon@jaggersoft.com

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
  && bundle config --global silence_root_warning 1 \
  && bundle install \
  && gem clean \
  && apk del build-dependencies \
  && rm -vrf /var/cache/apk/*

RUN export RACK_ENV='production'

# - - - - - - - - - - - - - - - - - - - - - -
# install docker-compose
# - - - - - - - - - - - - - - - - - - - - - -

ARG DOCKER_COMPOSE_VERSION=1.17.0
RUN apk add --no-cache curl \
 && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
 && apk del curl \
 && chmod +x /usr/local/bin/docker-compose

# - - - - - - - - - - - - - - - - - - - - - -
# [start-point create NAME --git=...] requires git clone
RUN apk add --update git

# [start-point create NAME --list=...] requires curl
RUN apk add --update curl

# - - - - - - - - - - - - - - - - - - - - - -
# install commander source

RUN adduser -D -H -u 19661 cyber-dojo

ARG HOME_DIR=/app
COPY . ${HOME_DIR}
WORKDIR ${HOME_DIR}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install tini (for pid 1 zombie reaping)
# https://github.com/krallin/tini

RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini

ENTRYPOINT [ "/sbin/tini", "--" ]
