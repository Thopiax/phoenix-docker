FROM elixir:1.4.2

MAINTAINER Ilker Guller <me@ilkerguller.com>

# System Env's
ENV REFRESHED_AT 2017-04-05
ENV ELIXIR_VERSION 1.4.2
ENV PHOENIX_VERSION 1.2.1
ENV NODE_VERSION 7
ENV PATH $PATH:node_modules/.bin:/opt/elixir-$ELIXIR_VERSION/bin

# Install System Dependencies + Nodejs
RUN apt-get update -q && apt-get upgrade -y \
    && apt-get install -y apt-transport-https curl wget git make sudo locales locales-all ca-certificates \
    && apt-get update -q \
    && curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash - \
    && sudo apt-get install -y nodejs \
    && apt-get clean -y \
    && rm -rf /var/cache/apt/*

# Create Certificate
RUN mkdir -p /etc/ssl/certs \
    && sudo update-ca-certificates

# Elixir requires UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Required NPM Packages
RUN npm install -g yarn

# Install Hex + Rebar + Phoenix
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez --force

WORKDIR /app
# ENV MIX_ENV prod

COPY mix.* /app/
RUN mix deps.get
# RUN mix deps.get --only prod

COPY package.json /app/
RUN npm install

COPY config /app/config/
RUN mix deps.compile
# RUN mix deps.compile --only prod

COPY . /app/
RUN mix compile
