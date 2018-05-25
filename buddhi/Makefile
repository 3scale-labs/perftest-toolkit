IMAGE_TAG ?= buddhi-v1.0.0
IMAGE_NAME ?= perftest-toolkit:$(IMAGE_TAG)
REGISTRY ?= quay.io/3scale

build:
	rake build -v
	docker build -t $(IMAGE_NAME) .

push:
	docker tag $(IMAGE_NAME) $(REGISTRY)/$(IMAGE_NAME)
	docker push $(REGISTRY)/$(IMAGE_NAME)

bash:
	docker run --rm -it $(IMAGE_NAME) bash

test-install:
	bundle install --path vendor/bundle

test:
	bundle exec rake spec

clean:
	bundle clean
	rm -rf vendor
