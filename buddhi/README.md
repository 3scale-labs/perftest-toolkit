# Buddhi - 3Scale AMP service setup and traffic generation tool

Responsibilities:

* 3Scale AMP db provisioning using 3scale backend internal api
* Provide services configuration for APIcast gateway
* Generates parametrized mock traffic definition for the load tool

## Usage

```shell
docker run --rm quay.io/3scale/perftest-toolkit:buddhi-v1.0.0 -h
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
"30dd63c1-4ee9-481e-b0ed-e7d10d4900c9","/1?user_key=2c6e8625ed43d064"
```
 - POST **/report/amp**: Send traffic file and generate metric counter report.
```bash
$ curl -X POST --data-binary "@traffic.csv" http://127.0.0.1:8089/report/amp 2>/dev/null | jq '.'
{
  "metrics": {
    "24b08f30-403e-4be7-83d8-984d6e93b91a": 7,
    "406127d9-0db7-4c77-8971-405f75ae94aa": 5,
    "7c1b7719-518c-45dc-9fd7-cbd56a7b921e": 2,
    "ce116219-2b63-4b6b-abb5-d52167be17cd": 2,
    "e28ae3f1-c3dd-43c9-8b66-52ea33b02e91": 6,
    "a53593fa-5d79-477b-a364-d6d3e6718b96": 3,
    "9cd322bd-ed72-490c-8a1b-cf1fc1831ce5": 2,
    "426d164f-2c87-4434-9d10-e6728024f422": 1,
    "1f47cdce-f802-46ce-bc11-8139f9d09612": 2
  }
}
```

## Development

## Run unit tests

```shell
make clean
make test-install
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
