FROM centos/ruby-25-centos7

ENV BUNDLE_WITHOUT=development:test

COPY pkg/*.gem ./pkg/

RUN bash -c 'gem install bundler -N && gem install pkg/*.gem -N'

ENTRYPOINT ["container-entrypoint", "perftest-toolkit-buddhi"]
