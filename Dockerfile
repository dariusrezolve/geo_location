FROM elixir:latest

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    apt-get install -y nodejs && \
    mix local.hex --force && \
    mix archive.install hex phx_new --force && \
    mix local.rebar --force


ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

EXPOSE 4000

CMD ["/app/entrypoint.sh"]
