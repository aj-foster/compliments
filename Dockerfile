FROM elixir:1.7.3 as build

LABEL maintainer="web@aj-foster.com"

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

COPY . .

RUN export COOKIE="ps-compliments-bot" && \
    export MIX_ENV=prod && \
    rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix release

RUN APP_NAME="compliments" && \
    RELEASE_DIR=`ls -d _build/prod/rel/compliments/releases/*/` && \
    mkdir export/ && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export


FROM erlang:21-alpine

COPY --from=build /export/ .

ENTRYPOINT [ "/bin/compliments" ]
CMD [ "foreground" ]