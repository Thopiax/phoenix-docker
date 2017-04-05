FROM elixir:1.4.2

MAINTAINER Ilker Guller <me@ilkerguller.com>

# System Env's
ENV REFRESHED_AT 2017-04-05
ENV ELIXIR_VERSION 1.4.2
ENV PHOENIX_VERSION 1.2.3
ENV NODE_VERSION 7
ENV PATH $PATH:node_modules/.bin:/opt/elixir-$ELIXIR_VERSION/bin

# Elixir requires UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create Certificate
RUN mkdir -p /etc/ssl/certs \
    && apk -U add ca-certificates \
    && update-ca-certificates

# Install System Dependencies
RUN apt-get update -q && apt-get upgrade -y \
    && apt-get install -y apt-transport-https curl wget git make sudo \
    && apt-get update -q \
    && curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash - \
    && sudo apt-get install -y nodejs \
    && apt-get clean -y \
    && rm -rf /var/cache/apt/*

# Install Required NPM Packages
RUN npm install -g yarn

# Install Hex + Rebar + Phoenix
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez --force

WORKDIR /app

CMD [
  "sh",
  "-c",
  "iex --version && mix deps.get && npm install && mix phoenix.server"
]