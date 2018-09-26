FROM ubuntu:18.04
LABEL maintainer="web@aj-foster.com"

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates rsync wget \
            build-essential curl gnupg && \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends erlang=1:21.0.6-1 elixir=1.7.3-1 && \
    mix local.hex --force && \
    mix local.rebar --force
