FROM elixir:1.7.3
LABEL maintainer="web@aj-foster.com"

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN mix local.hex --force && \
        mix local.rebar --force
