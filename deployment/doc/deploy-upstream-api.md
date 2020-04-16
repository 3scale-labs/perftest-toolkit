## Deploy Upstream API

If you don’t want to use your own Upstream API, the following steps show how to deploy the *echo-api* Upstream test API.
On 3scale, tests were carried out using an *echo-api* as backend api endpoint.
The service will answer to http requests with response body including information from http requests.
It is very very fast and response body tend to be very small.

**Requirements**:

Control node:
* ansible >= 2.3.1.0

Managed node host:
* Docker >= 1.12
* python >= 2.6
* docker-py >= 1.7.0

**Steps**:

Checkout playbooks

```bash
$ git clone git@github.com:3scale/perftest-toolkit.git
$ cd deployment
```

Edit the *ansible_host* parameter of the ‘upstream’ entry in the ‘hosts’ file located at the root of the repository by replacing *<host>* with the host IP address/DNS name of the machine where you want to install the *echo-api* test.

For example:
```
upstream ansible_host=myupstreamhost.addr.com ansible_user=centos
```

Execute the playbook that installs and configures the *echo-api* upstream test API via Ansible.

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

Some considerations worth to be noted. Upstream API host’s hardware resources should not be performance tests bottleneck.
Enough cpu, memory and network resources should be available. Upstream API endpoint can be any HTTP endpoint service. Some constraints:
* Must be fast. Must never be performance bottleneck
* Generated response body should be small. Network should not be bottleneck, unless this effect is what is being tested
