# perftest-toolkit

[![Docker Repository on Quay](https://quay.io/repository/3scale/perftest-toolkit/status "Docker Repository on Quay")](https://quay.io/repository/3scale/perftest-toolkit)

This repo has tools and deployment configs for a performance testing environment to be able to run performance tests of a 3scale API Management solution, focusing on the traffic intensive parts of the solution (the API Gateway and the Service Management API).

We have open sourced it to enable partners, customers and support engineers to run their own performance tests on "self-managed" (i.e. Not SaaS) installations of the 3scale API Management solution.

By running performance test with the same tools, scripts, traffic patterns and measurements as we at 3scale do, we hope it will help produce results that can be more easily compared with the results we achieve in our regular in-house performance testing and that we can run internally.

The goal is to help to resolve doubts or issues related to scalability or performance more quickly and easily - allowing you to achieve the high levels of low-latency performance we strive for and ensure in our own internal testing.

## Table of Contents

* [High level overview](#high-level-overview)
* [Prerequisites](#prerequisites)
* [Deploy injector](#deploy-injector)
   * [Common settings](#common-settings)
   * [Test your 3scale services](#test-your-3scale-services)
   * [Setup traffic profiles](#setup-traffic-profiles)
* [Run tests](#run-tests)
* [Sustained load](#sustained-load)
* [Troubleshooting](#troubleshooting)
   * [Check apicast gateway configuration](#check-apicast-gateway-configuration)
   * [Check backend listener traffic](#check-backend-listener-traffic)
   * [Check upstream service traffic](#check-upstream-service-traffic)

Generated using [github-markdown-toc](https://github.com/ekalinin/github-markdown-toc)

## High level overview

High level overview is quite simple. Main components are represented in the diagram below.

* Injector: Source of HTTP/HTTPS traffic requests
* Openshift Container Platform with 3scale installed
* Upstream API: Also named as backend API, this is the final API service as an HTTP traffic endpoint. Optionally, for testing purposes, [deploy Upstream API](deployment/doc/deploy-upstream-api.md).
* Test Configurator (Buddhi): 3scale setup and traffic generation tool

![Test setup](deployment/doc/infrastructure.png "Infrastructure")

## Prerequisites
* An OpenShift cluster with 3scale installed. You can also use the OpenShift cluster to host your Upstream API (or you can host it elsewhere).
* A machine to run the hyperfoil injector (for example, an AWS EC2 Instance). Keep in mind this machine will be running performance tests so make sure it has sufficient compute resources to not be the bottleneck.
  * This machine can serve as both the control node and the managed node for the injector _**or**_ it can just be the managed node. For example, you could use your local machine as the injector's control node and the remote machine as the injector's managed node.

The perftest-toolkit will take care of:
* Installing hyperfoil on the remote machine (e.g. the AWS EC2 instance)
* Running [Buddhi](buddhi/README.md)
* Creating 3scale products, backends, etc. (**only** if using [traffic profiles](buddhi/README.md#profiles))

## Deploy injector

There are **two** ways of running your tests and the injector has to be configured accordingly.

* [Test your own 3scale services](#test-your-3scale-services): The injector will be custom configured to use your 3scale products (a.k.a. services).

* [Setup traffic profiles](#setup-traffic-profiles): Configure your performance tests to use synthetically generated traffic based on traffic models.

**Requirements**:

Control node:
* ansible >= 2.9.14
* python >= 3.0
* Install ansible requirements
```bash
cd deployment
ansible-galaxy install -r requirements.yaml
```

Managed node host:
* Docker >= 1.12
* python >= 2.7
* docker-py >= 1.7.0

Make sure that the injector host’s hardware resources is not the performance tests bottleneck. Enough cpu, memory and network resources should be available.

### Common settings

**1.** Provide **hyperfoil controller** host IP address or DNS name and at least one **hyperfoil agent** host IP address or DNS name to the [deployment/hosts](deployment/hosts) file. For example:

```
upstream ansible_host=controllerhost.example.com ansible_user=root

[hyperfoil_controller]
controllerhost.example.com ansible_host=controllerhost.example.com ansible_user=root

[hyperfoil_agent]
agent1 ansible_host=agenthost.example.com ansible_user=root
```

**Note 01**: make sure defined ansible user has ssh login access to the host without password.

**Note 02**: make sure hyperfoil controller host has ssh login access to the agent host without password.

More than one hyperfoil agent can be configured. Useful when the injector becomes a bottleneck. For example to configure two agents:

```
upstream ansible_host=controllerhost.example.com ansible_user=root

[hyperfoil_controller]
controllerhost.example.com ansible_host=controllerhost.example.com  ansible_user=root

[hyperfoil_agent]
agent1 ansible_host=agenthost01.example.com ansible_role=root
agent2 ansible_host=agenthost02.example.com ansible_role=root
```

**2.** By default, the injector will generate HTTPS traffic on the port number 443. You can change this setting editing the `injector_hyperfoil_target_protocol` and `injector_hyperfoil_target_port` parameters in the [deployment/group_vars/all.yml](deployment/group_vars/all.yml) file.

**3.** If you're having ssh issues when running ansible playbooks, try adding an ssh certificate to [deployment/ansible.cfg](deployment/ansible.cfg). Otherwise, remove the `-i "/path/to/ssh/certificate"` from this [line](https://github.com/3scale-labs/perftest-toolkit/blob/c906ca3349a34d9fe6e72d9b28570268387257fd/deployment/ansible.cfg#L11).

### Test your 3scale services

Skip these steps if using traffic profiles. These steps will configure the injector to use your 3scale services.

**1.** Configure the following settings in [deployment/roles/user-traffic-reader/defaults/main.yml](deployment/roles/user-traffic-reader/defaults/main.yml) file:
* `threescale_portal_endpoint`: 3scale portal endpoint
* `threescale_services`: Select the 3scale services you want to use for the tests. Leave it empty to use them all.

```
---
# defaults file for user-traffic-reader

# URI that includes your password and portal endpoint in the following format: <schema>://<password>@<admin-portal-domain>.
# The <password> can be either the provider key or an access token for the 3scale Account Management API.
# <admin-portal-domain> is the URL used to log into the admin portal.
# Example: https://access-token@account-admin.3scale.net
threescale_portal_endpoint: <THREESCALE_PORTAL_ENDPOINT>

# Comma separated list of services (Id's or system names)
# If empty, all available services will be used
threescale_services: ""
```

**2.** Execute the playbook `injector.yml` to deploy injector.
```bash
cd deployment/
ansible-playbook -i hosts injector.yml
```

### Setup traffic profiles

Skip these steps if testing your own 3scale services. These steps will set up 3scale services for performance testing.

**1.** Configure the following settings in [deployment/roles/profiled-traffic-generator/defaults/main.yml](deployment/roles/profiled-traffic-generator/defaults/main.yml):
* `threescale_portal_endpoint`: 3scale portal endpoint
* `traffic_profile`: Currently [available profiles](buddhi/README.md#profiles): `simple, backend, medium, standard`
* `private_base_url`: Private Base URL used for the tests. Make sure your private application behaves like an echo api service.
* `public_base_url`: Optionally, configure the `Public Base URL` used for the tests for self-managed apicast environments. Otherwise, leave it empty.

```
---
# defaults file for profiled-traffic-generator

# URI that includes your password and portal endpoint in the following format: <schema>://<password>@<admin-portal-domain>.
# The <password> can be either the provider key or an access token for the 3scale Account Management API.
# <admin-portal-domain> is the URL used to log into the admin portal.
# Example: https://access-token@account-admin.3scale.net
threescale_portal_endpoint: <THREESCALE_PORTAL_ENDPOINT>

# Used traffic for performance testing is not real traffic.
# It is synthetically generated traffic based on traffic models.
# Information about available traffic profiles (or test plans) can be found here:
# https://github.com/3scale/perftest-toolkit/blob/master/buddhi/README.md#profiles
# Currently available profiles: [ simple | backend | medium | standard ]
traffic_profile: <TRAFFIC_PROFILE>

# Private Base URL
# Make sure your private application behaves like an echo api service
# example: https://echo-api.3scale.net:443
private_base_url: <PRIVATE_BASE_URL>

# Public Base URL
# Public address of your API gateway in the production environment.
# Optional. When it is left empty, public base url will be the hosted gateway url
# example: https://gw.example.com:443
public_base_url: <PUBLIC_BASE_URL>
```

**2.** Execute the playbook `profiled-injector.yml` to deploy injector.
```bash
cd deployment/
ansible-playbook -i hosts profiled-injector.yml
```

## Run tests

**Note**: If you'd prefer to run the tests using [Locust](https://locust.io/), refer to [this guide](locust/README.md) and skip the below steps.

**1.** Configure testing settings in [deployment/run.yml](https://github.com/3scale-labs/perftest-toolkit/blob/c906ca3349a34d9fe6e72d9b28570268387257fd/deployment/run.yml#L9-L11):

```
USERS_PER_SEC: Requests per second
DURATION_SEC: Duration of the performance test in seconds
SHARED_CONNECTIONS: Number of connections open per target HOST
```

**2.** Run tests

```bash
ansible-playbook -i hosts -i benchmarks/3scale.csv run.yml
```

**3.** View Report

The test results of the last execution are automatically stored in **deployment/benchmarks/<runid>.html**.
The html file can be directly opened with your favorite web browser.

## Sustained load

Some performance test are looking for *peak* and *sustained* traffic maximum performance.
*Sustained* traffic is defined as traffic load where *Job Queue* size is always at low levels, or even empty.
For *sustained* traffic performance benchmark, *Job Queue* must be monitorized.

This is a small guideline to monitor *Job Queue* size:

- Get backend redis pod

```bash
$ oc get pods | grep redis
backend-redis-2-nkrkk         1/1       Running   0          14d
```

- Get Job Queue size

```bash
$ oc rsh backend-redis-2-nkrkk /bin/sh -i -c 'redis-cli -n 1 llen resque:queue:priority'
(integer) 0
```

## Troubleshooting

Sometimes, even though all deployment commands run successfully, performance traffic may be broken.
This might be due to a misconfiguration in any stage of the deployment process.
When performance HTTP traffic response codes are not as expected, i.e. **200 OK**,
there are few checks that can be very handy to find out configuration mistakes.

### Check apicast gateway configuration

First, scale down *apicast-production* service to just one pod.

Monitor pod's logs for traffic accesslog.

```bash
oc logs -f apicast-production-X-podId
```

[Run tests](#run-tests) and check for logs.

Check response codes on accesslog.

If accesslog shows *could not find service for host* error, then the configured virtual hosts do not match traffic *Host* header. For example:
```
2018/06/05 13:32:41 [warn] 25#25: *883 [lua] errors.lua:43: get_upstream(): could not find service for host: 9ccd143c-dbe4-471c-9bce-41df7dde8d99.benchmark.perftest.3sca.net, client: 10.130.4.1, server: _, request: "GET /855aaf5c-a199-4145-a3ab-ea9402cc35db/some-request?user_key=32313d20d99780a5 HTTP/1.1", host: "9ccd143c-dbe4-471c-9bce-41df7dde8d99.benchmark.perftest.3sca.net"
```

Another issue might be when response codes are *404 Not Found*. Then proxy-rules do not match traffic path.

In anyone of the previous cases, it seems that *apicast gateway* does not have the latest configuration.
Either restart the pod(s) or wait until process fetches the new configuration based on
*APICAST_CONFIGURATION_CACHE* apicast configuration parameter.

The pods can be restarted by scaling the Deployment to 0 and then scaling back to the desired number of pods.

```bash
oc scale deployment apicast-production --replicas=0
oc scale deployment apicast-production --replicas=2
```

### Check backend listener traffic

First, scale down *backend-listener* service to just one pod.
```bash
oc scale deployment backend-listener --replicas=1
```

Then monitor the pod's logs for traffic accesslog.
```bash
oc logs -f backend-listener-X-podId
```

[Run tests](#run-tests) and check for logs.

If no logs are shown, check [gateway troubleshooting section](#check-apicast-gateway-configuration)

If logs are shown, check response codes on accesslog. Other than *200 OK* means
- *redis* is down,
- *redis* address is misconfigured in *backend-listener*
- redis does not have required data to authenticate requests

### Check upstream service traffic

When *backend-listener* accesslog shows requests are being answered with *200 OK* response codes,
the last usual suspect is upstream or upstream configuration.

Check *upstream* uri is correctly configured in your 3scale configuration.
