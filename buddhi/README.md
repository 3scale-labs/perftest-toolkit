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

## Contributing

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
