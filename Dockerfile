FROM ruby:2.3-slim-jessie

RUN apt-get update
RUN apt-get install -y libmysqlclient-dev libmagickwand-dev imagemagick build-essential libsqlite3-dev

ADD Gemfile* subscity/
WORKDIR subscity
RUN bundle install

COPY . .
COPY db/.credentials.example db/.credentials.rb
COPY config/.token.rb.example config/.token.rb
EXPOSE 3000

ENTRYPOINT ["padrino"]
CMD ["start", "-h", "0.0.0.0", "-a", "thin", "-e", "production"]
