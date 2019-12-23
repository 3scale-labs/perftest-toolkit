GIT_VERSION=$(shell git describe --tags --abbrev=0)
VERSION=$(GIT_VERSION)
IMAGE_TAG ?= buddhi-$(VERSION)
IMAGE_NAME ?= perftest-toolkit:$(IMAGE_TAG)
LATEST_IMAGE ?= perftest-toolkit:buddhi-v2-latest
REGISTRY ?= quay.io/3scale

.PHONY: build, push, bash, deps, test, clean

build: deps
	bundle exec rake build -v
	docker build -t $(IMAGE_NAME) .

push:
	docker tag $(IMAGE_NAME) $(REGISTRY)/$(IMAGE_NAME)
	docker push $(REGISTRY)/$(IMAGE_NAME)
	docker tag $(IMAGE_NAME) $(REGISTRY)/$(LATEST_IMAGE)
	docker push $(REGISTRY)/$(LATEST_IMAGE)

bash:
	docker run --rm -it $(IMAGE_NAME) bash

deps:
	bundle install --path vendor/bundle

test: deps
	bundle exec rake spec

clean:
	rm -rf vendor
	rm -rf pkg
	rm -rf coverage
