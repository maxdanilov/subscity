FROM ruby:2.3-slim-jessie

RUN apt-get update
RUN apt-get install -y libmysqlclient-dev libmagickwand-dev imagemagick build-essential libsqlite3-dev

ADD Gemfile* subscity/
WORKDIR subscity
RUN bundle install

EXPOSE 3000
ENV SC_ENV production

COPY . .

CMD padrino start -h 0.0.0.0 -a thin -e ${SC_ENV}
