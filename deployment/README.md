# 3Scale AMP service setup for testing

## Introduction

This documents aims to provide comprehensive guide of the setup and execution of performance tests.
The reader should be able to reproduce performance tests using the same tools and deployment configurations.

## High level overview

High level overview is quite simple. Main components are represented in the diagram below.

* Injector: Source of HTTP traffic requests
* Openshift Container Platform with 3Scale AMP deployed
* Upstream API: The API that will provide the final API service as an HTTP traffic endpoint. For testing purposes, steps to use a fictional API named *echo-api* are also provided in this document
* Test Configurator (Buddhi): AMP setup and traffic generation tool

![Test setup](doc/infrastructure.png "Infrastructure")

The steps to follow to be able to execute performance tests are:

1. Deploy & Setup of the provisioning tool
1. Deploy & Setup Upstream API
1. Deploy & Setup Openshift platform
1. Deploy & Setup 3scale AMP on Openshift
1. Deploy & Run Test configurator
1. Deploy & Setup Injector
1. Run tests

## Deployment & Setup provisioning tool

Ansible is used for easy and quick setup. The objective is make it easy for the users the deployment and setup of all the components.

The minimum Ansible required version to use is:

```bash
$ ansible --version
ansible 2.3.1.0
```

The 3scale performance testing ansible project can be obtained from the following GitHub repository:

```bash
$ git clone git@github.com:3scale/perftest-toolkit.git
$ cd deployment
```

The required Ansible version and 3scale performance testing ansible project must be installed in a host with SSH connectivity against the machines where the performance testing components will be provisioned.

From now on, relative paths that appear in this document will be relative to the ’deployment’ directory of the 3scale performance testing ansible project in the coming sections unless otherwise noted.

## Deploy & Setup Upstream API

If you don’t want to use your own Upstream API, the following steps show how to configure the *echo-api* Upstream test API:

Upstream API host’s hardware resources should not be performance tests bottleneck. Enough cpu, memory and network resources should be available.

Upstream API endpoint can be any HTTP endpoint service. Some constraints
* Must be fast. Must never be performance bottleneck
* Generated response body should be small. Network should not be bottleneck, unless this effect is what is being tested

On 3scale, tests were carried out using an *echo-api* as backend api endpoint.
The service will answer to http requests with response body including information from http requests.
It is very very fast and response body tend to be very small.

There is an Ansible playbook that can be used to deploy this *echo-api* upstream test API.
The use of this test API is not required to perform the performance testing.
You can provide your own Upstream API and configure it in Buddhi’s configuration (see the Buddhi section for more details on how to do it).

Requirements:

Installed packages requirements for the host:

* Docker >= 1.12
* python >= 2.6
* docker-py >= 1.7.0

**Steps**:

* Edit the *ansible_host* parameter of the ‘upstream’ entry in the ‘hosts’ file located at the root of the repository by replacing *<host>* with the host IP address/DNS name of the machine where you want to install the *echo-api* test.
For example:
```
upstream ansible_host=myupstreamhost.addr.com ansible_user=centos
```
* Execute the playbook that installs and configures the *echo-api* upstream test API via Ansible.
```bash
ansible-playbook -i hosts upstream.yml
```

After this, the *echo-api* service should be listening on port **8081**

Test that the *echo-api* upstream test API has been installed and configured correctly.
To do this you can test that the service responds correctly to HTTP requests:

```bash
$ curl -v http://127.0.0.1:8081
* About to connect() to 127.0.0.1 port 8081 (#0)
*   Trying 127.0.0.1…
* Connected to 127.0.0.1 (127.0.0.1) port 8081 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: 127.0.0.1:8081
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: openresty/1.13.6.1
< Date: Mon, 14 May 2018 15:38:38 GMT
< Content-Type: text/plain
< Transfer-Encoding: chunked
< Connection: keep-alive
<
GET / HTTP/1.1
User-Agent: curl/7.29.0
Host: 127.0.0.1:8081
Accept: */*
* Connection #0 to host 127.0.0.1 left intact
```

## Deploy & Setup Openshift platform

Installation and setup of OCP is out of scope of this document.
However it is worth noting that there are many aspects from the process that might affect performance tests results.
Among others:

* Number of computer nodes
* Number of router nodes
* Instance types
* Persistence deployment
* OCP release version

There is a comprehensive [installation guide for release 3.7](https://docs.openshift.com/container-platform/3.7/install_config/index.html).

## Deploy & Setup 3Scale AMP

Deployment and setup of 3Scale AMP is out of scope of this document.
However it is worth noting that there are many aspects from the process that might affect performance tests results. Specifically:

* Number of apicast gateway pods
* Number of apicast workers
* Number of backend listener pods
* Number of backend listener puma workers
* Number of backend worker pods
* 3Scale AMP release version
* Redis persistence type

There is a comprehensive [installation guide for AMP release 2.1](https://access.redhat.com/documentation/en-us/red_hat_3scale/2.1/html/infrastructure/onpremises-installation).

### Configuration 3Scale AMP

Most of the configuration coming from default AMP templates is ok for performance testing.
Some configuration parameters (in deployment config) that were applied during testing:

**apicast-production deployment config**
```
- name: APICAST_RESPONSE_CODES
  value: "false"
```
**backend-listener deployment config**
```
 - name: CONFIG_NOTIFICATION_BATCH
   value: "1000000"
```
**backend-redis deployment config** -> Resource Limits
```
CPU resource limits: request: 1  limit: 2
```

### Wildcard route
* Enable wildcard routes support
  * Go to Openshift dashboard, go to *Default* project.
  * Go to *Applications* -> *Deployments*. Select *router*
  * Go to *Environment* tab, check the following wildcard configuration is set.
```
ROUTER_ALLOW_WILDCARD_ROUTES = true
```

Wait few seconds until routers have restarted.

* Create wildcard route
  * Go to AMP project.
  * Go to *Applications* -> *Routes*
  * Push on *Create Route* button.
  * Fill the following settings:

```
Name: <any meaninful name>
Hostname: *.benchmark.<OCP_domain>
Path: /
Service: apicast-production
Target-Port: 8080 -> 8080
Check *Secure Route* when *https* is used
```
  * Push on *Create* button.

## Deploy & Run Test Configurator

Test configurator (a.k.a. [**buddhi**](/buddhi)) is a service with the following responsibilities:

* AMP system setup based on selected traffic profile. Call AMP internal API to provision required information for a valid traffic
* Provide test specific configuration for AMP gateways
* Generate traffic information for jmeter test plan

Requirements:

Installed packages requirements for the host:

* Docker >= 1.12
* python >= 2.6
* docker-py >= 1.7.0

Steps:

* Configure Test Configurator host

Set *ansible_host* attribute of *buddhi* host

```
File: hosts

buddhi ansible_host=<buddhi_uri> ansible_user=centos
```

* Configure AMP backend uri
  * Go to Openshift dashboard, go to *Applications* -> *Routes*.
  * Get *Hostname* value of route named *backend-route*.
  * Fill **buddhi_internal_api_uri** with that value.

```
File: roles/buddhi-configurator/defaults/main.yml

buddhi_internal_api_uri: "<backend_uri>"
```

* AMP backend service basic authentication
  * Go to Openshift dashboard, go to *Applications* -> *Deployments* -> *backend-listener*
  * Go to *Environment* tab, you will get basic authentication information from  [*CONFIG_INTERNAL_API_USER*, *CONFIG_INTERNAL_API_PASSWORD*] settings.
```
File: roles/buddhi-configurator/defaults/main.yml

buddhi_backend_username: "<backend_username>"
buddhi_backend_pass: "<backend_basic_auth_pass>"
```

* Configure traffic profile

Used traffic for performance testing is not real traffic. It is synthetically generated traffic based on traffic models.
Information about available traffic profiles (or test plans) can be found [here](/buddhi#usage).
Traffic load in terms of requests per second will be specified when running tests.

```
File: roles/buddhi-configurator/defaults/main.yml

buddhi_traffic_profile: [ simple | onprem | saas ]
```

*saas* profile takes half of a minute to provision all data. Let it finish before going ahead.

* Configure upstream api url

Private address of the upstream API that will be called by the API gateway.
Check available [*echo-api* service deployment section](#deploy-&-setup-upstream-api) if you do not want to test with your own api service.

```
File: roles/buddhi-configurator/defaults/main.yml

buddhi_upstream_uri: "<your-api-uri>"
```

* Configure wildcard domain

Domain that resolves to your OCP cluster

```
File: roles/buddhi-configurator/defaults/main.yml

buddhi_wilcard_domain: benchmark.<OCP_domain>
```

* Execute the playbook that installs and configures via Ansible

```bash
ansible-playbook -i hosts buddhi.yml
```

* Update *apicast gateway* setting of configuration provider

Change apicast gateway deployment config

  * Go to Openshift dashboard, go to *Applications* -> *Deployments* -> *apicast-production*
  * Go to *Environment* tab, set *THREESCALE_PORTAL_ENDPOINT* environment variable to Test Configurator hostname and port in uri format. Port number can be read from file **group_vars/all.yml**, *buddhi_port* key.

On deployment config change, apicast-production pods should *reboot* automatically. Otherwise, force them manually.

## Deploy & Setup Injector

Injector host’s hardware resources should not be performance tests bottleneck. Enough cpu, memory and network resources should be available.

Requirements:

Installed packages requirements for the host:

* Docker >= 1.12
* python >= 2.6
* docker-py >= 1.7.0

**Steps**:

* Edit the *ansible_host* parameter of the *injector* entry by replacing **<injector_host>** with the host IP address/DNS name of the machine where you want to install the injector component. For example:
```
File: hosts

injector ansible_host=myinjectorhost.addr.com ansible_user=centos
```

* Edit the **injector_jmeter_target_host** parameter replacing *<jmeter_target_host>* with the route endpoint of the AMP gateway. For example:
```
File: roles/injector-configurator/defaults/main.yml

Injector_jmeter_target_host: myroutehostname.com
```

By default, injector will perform HTTP requests to the port 80 of the target host. You can change this by editing the *injector_jmeter_protocol* (http/https) and *injector_jmeter_target_port* parameters.

* Execute the playbook that installs and configures the injector via Ansible
```bash
ansible-playbook -i hosts injector.yml
```

After this, the injector should be already configured and available using the **/usr/local/bin/3scale-perftest** binary (see ‘Run tests’ section)

## Run tests

Requirements:

* Injector already installed and configured
* Openshift Container Platform with 3Scale AMP deployed
* An Upstream API already installed and configured as backend of the 3Scale AMP
* Test Configurator (Buddhi): AMP setup and traffic generation tool

To perform tests the *3scale-pertest* tool is available from where the injector is installed. The usage of the 3scale-perftest tool is:

```bash
$ 3scale-perftest -h
Usage:
    3scale-perftest -h                       Display this help message.
    3scale-perftest -r RPS -d DUR -t THRS    Launch 3scale perf test.

Where:
-r RPS  : Maximum requests per second to send
-d DUR  : Duration of the performance test in seconds
-t THRS : Number of threads (parallel connections) to use
```

For example:

```bash
$ 3scale-perftest -r 10000 -d 600 -t 50
```

The test results of the last execution are automatically stored in **/opt/3scale-perftest/reports**.
This directory can be obtained and then the **report/index.html** can be opened to view the results.
