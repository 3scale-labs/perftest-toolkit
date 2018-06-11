# Buddhi - 3Scale AMP service setup and traffic generation tool

Responsibilities:

* 3Scale AMP db provisioning using 3scale backend internal api
* Provide services configuration for APIcast gateway
* Generates parametrized mock traffic definition for the load tool

## Usage

```shell
docker run --rm quay.io/3scale/perftest-toolkit:buddhi-latest -h
usage: buddhi [options]
    -T, --testplan      load test definition key: ["saas", "onprem", "simple"]
    -I, --internal-api  backend internal api endpoint
    -B, --backend       backend endpoint for apicast
    -U, --username      backend internal api user
    -P, --password      backend internal api password
    -E, --endpoint      API upstream endpoint
    -A, --apicast       APIcast wildcard domain
    -p, --port          listen port
    -h, --help
```

Currently implemented test plans:
 - [simple](doc/simple.md)
 - [saas](doc/saas.md)
 - [onprem](doc/onprem.md)

Traffic files can be downloaded using api endpoints:
 - **/paths/backend**: request path. Add *lines* query param for any number of valid random requests.
```bash
$ curl http://127.0.0.1:8089/paths/backend?lines=1
/transactions/authrep.xml?provider_key=5350a1bd-b476-44fb-adb2-e1c87e58c960&service_id=39395bbc-4ea2-46d9-878b-188c1ce92e33&user_key=f5a8c86e7bbdcccf
```
 - **/paths/amp**: CSV formatted file with **Host, Path*^** header. Add *lines* query param for any number of valid random requests.
```bash
$ curl http://127.0.0.1:8089/paths/amp?lines=1
"53f07c14-e35e-4bfa-b0b1-9d3a993fad14.benchmark.3sca.net","/1?app_id=6641c22185bbf204&app_key=3d0112323ceef116"
```
 - POST **/report/amp**: Send traffic file and generate metric counter report.

Report shows usage for every metric involved in traffic.

Format
```
{ service_id => { metric_id: counter} }
```

Traffic information can be generated using */paths/amp* endpoint as follows:

```bash
$ curl http://127.0.0.1:8089/paths/amp?lines=5 2>/dev/null > traffic.csv
$ cat traffic.csv
"53f07c14-e35e-4bfa-b0b1-9d3a993fad14.benchmark.3sca.net","/1?app_id=ddfa9a8842a3822e&app_key=73418183a69b027a"
"e75ef4f7-54da-4ec6-a4b2-33a163764385.benchmark.3sca.net","/1?app_id=5e4618aa57d801cd&app_key=fe4db52e5e86668f"
"e75ef4f7-54da-4ec6-a4b2-33a163764385.benchmark.3sca.net","/11?app_id=ceeeb23abfd0adfd&app_key=fbdfae99a587811e"
"31b75b9b-fbb4-4223-8736-b93c34676f04.benchmark.3sca.net","/1?user_key=aa5736e41a3888db"
"e75ef4f7-54da-4ec6-a4b2-33a163764385.benchmark.3sca.net","/111?app_id=ca2f8ff8b0a8707c&app_key=4b349db5bb77b9db"
```

Then, metric report can be generated requesting */report/amp* endpoint as follows:

```bash
$ curl -X POST --data-binary "@traffic.csv" http://127.0.0.1:8089/report/amp 2>/dev/null
{"53f07c14-e35e-4bfa-b0b1-9d3a993fad14":{"6527c16b-dfeb-46e7-93d8-4eef0a6abbe3":1,"0dfb13fa-410e-4394-9fad-f0b785e1e680":1},"e75ef4f7-54da-4ec6-a4b2-33a163764385":{"dabdb86c-5344-4ff5-b8c7-65740357ecc6":6,"439402ef-ee9a-4c2a-856e-59928a3cef10":3,"e7265d03-efa7-4641-80b6-6d4a0d44713b":2,"937ebcef-1afd-4498-91a7-696c069f4668":1},"31b75b9b-fbb4-4223-8736-b93c34676f04":{"267c1777-53f7-4568-b9c0-2af28571a1dc":1,"2641b733-2030-4fac-9248-c1b8d3a4f02b":1}}
```

Pretty printed

```json
{
  "53f07c14-e35e-4bfa-b0b1-9d3a993fad14": {
    "6527c16b-dfeb-46e7-93d8-4eef0a6abbe3": 1,
    "0dfb13fa-410e-4394-9fad-f0b785e1e680": 1
  },
  "e75ef4f7-54da-4ec6-a4b2-33a163764385": {
    "dabdb86c-5344-4ff5-b8c7-65740357ecc6": 6,
    "439402ef-ee9a-4c2a-856e-59928a3cef10": 3,
    "e7265d03-efa7-4641-80b6-6d4a0d44713b": 2,
    "937ebcef-1afd-4498-91a7-696c069f4668": 1
  },
  "31b75b9b-fbb4-4223-8736-b93c34676f04": {
    "267c1777-53f7-4568-b9c0-2af28571a1dc": 1,
    "2641b733-2030-4fac-9248-c1b8d3a4f02b": 1
  }
}
```

## Development

## Run unit tests

```shell
make clean
make test
```

## Build docker image

```shell
make clean
make build'
```

## Releasing

```shell
make push
```
