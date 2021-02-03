FROM quay.io/3scale/perftest-toolkit:ruby2.7
MAINTAINER Eguzki Astiz Lezaun <eastizle@redhat.com>

WORKDIR /usr/src/app
COPY . .
RUN gem build perftest-toolkit-buddhi.gemspec
RUN gem install perftest-toolkit-buddhi-*.gem --no-document
RUN adduser --home /home/buddhiuser buddhiuser
WORKDIR /home/buddhiuser

# clean up
RUN rm -rf /usr/src/app

# Drop privileges
USER buddhiuser
