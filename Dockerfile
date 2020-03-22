FROM mkenney/npm:node-8-alpine as asset-compiler
WORKDIR /assets/
RUN npm config set unsafe-perm true
RUN npm install -g uglify-js less@2.7.3 less-plugin-clean-css
COPY public/less/* ./
COPY public/javascripts/default.js ./
RUN lessc --clean-css design.less design.css
RUN uglifyjs default.js --compress --mangle --output default.min.js

FROM ruby:2.3-slim-jessie AS base
RUN apt-get update && apt-get install -y libmysqlclient-dev libmagickwand-dev imagemagick build-essential \
    libsqlite3-dev cron nano git wget mysql-client mutt

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "subscity" > /etc/mailname
COPY dockerfiles/exim4.conf /etc/exim4/update-exim4.conf.conf
RUN update-exim4.conf

COPY dockerfiles/.bashrc /etc/bash.bashrc

FROM base AS base-gems
WORKDIR subscity
ADD Gemfile* ./
RUN bundle install
COPY --from=asset-compiler /assets/design.css public/stylesheets/
COPY --from=asset-compiler /assets/default.min.js public/javascripts/

FROM base-gems
EXPOSE 3000
ENV SC_ENV=production
COPY . .

ENTRYPOINT [ "/bin/sh" ]
CMD [ "dockerfiles/entrypoint.sh" ]
