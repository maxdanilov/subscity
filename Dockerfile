FROM ruby:2.3-slim-jessie

RUN apt-get update
RUN apt-get install -y libmysqlclient-dev libmagickwand-dev imagemagick build-essential libsqlite3-dev cron
RUN apt-get install -y nano git wget mysql-client mutt

ADD Gemfile* subscity/
WORKDIR subscity
RUN bundle install

EXPOSE 3000
ENV SC_ENV=production

COPY . .

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "subscity" > /etc/mailname
COPY scripts/dockerfiles/exim4.conf /etc/exim4/update-exim4.conf.conf
RUN update-exim4.conf

COPY scripts/dockerfiles/.bashrc /etc/bash.bashrc

ENTRYPOINT [ "/bin/sh" ]
CMD [ "scripts/entrypoint.sh" ]
