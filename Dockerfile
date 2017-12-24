FROM ruby:2.3-slim-jessie

RUN apt-get update
RUN apt-get install -y libmysqlclient-dev libmagickwand-dev imagemagick build-essential libsqlite3-dev cron git nano

ADD Gemfile* subscity/
WORKDIR subscity
RUN bundle install

EXPOSE 3000
ENV SC_ENV=production

COPY . .

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY scripts/dockerfiles/.bashrc /etc/bash.bashrc

ENTRYPOINT [ "/bin/sh" ]
CMD [ "scripts/entrypoint.sh" ]
