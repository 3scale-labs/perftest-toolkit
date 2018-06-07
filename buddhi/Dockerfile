FROM centos/ruby-23-centos7

ENV BUNDLE_WITHOUT=development:test

COPY pkg/*.gem ./pkg/

RUN bash -c 'gem install bundler --version 1.14.4 -N && gem install pkg/*.gem -N'

ENTRYPOINT ["container-entrypoint", "perftest-toolkit-buddhi"]
