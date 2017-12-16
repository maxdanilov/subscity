FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y git software-properties-common

RUN apt-add-repository -y ppa:rael-gc/rvm
RUN apt-get update
RUN apt-get install -y rvm libmysqlclient-dev libmagickwand-dev imagemagick

RUN /bin/bash -l -c "rvm install 2.3.0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

RUN git clone https://github.com/maxdanilov/subscity.git
WORKDIR subscity
RUN /bin/bash -l -c "bundle install"

ADD db/.credentials.example db/.credentials.rb
ADD config/.token.rb.example config/.token.rb
EXPOSE 3000

ENTRYPOINT ["/bin/bash"]
CMD ["-l", "-c", "bundle exec padrino start -h 0.0.0.0 -a thin -e production"]
