# Buddhi - 3scale traffic file generation tool

Responsibilities:

* Generate CSV formatted file with **Host, Path*^** header.
```bash
$ cat traffic.csv
"53f07c14-e35e-4bfa-b0b1-9d3a993fad14.benchmark.3sca.net","/1?app_id=ddfa9a8842a3822e&app_key=73418183a69b027a"
"e75ef4f7-54da-4ec6-a4b2-33a163764385.benchmark.3sca.net","/1?app_id=5e4618aa57d801cd&app_key=fe4db52e5e86668f"
"e75ef4f7-54da-4ec6-a4b2-33a163764385.benchmark.3sca.net","/11?app_id=ceeeb23abfd0adfd&app_key=fbdfae99a587811e"
"31b75b9b-fbb4-4223-8736-b93c34676f04.benchmark.3sca.net","/1?user_key=aa5736e41a3888db"
"e75ef4f7-54da-4ec6-a4b2-33a163764385.benchmark.3sca.net","/111?app_id=ca2f8ff8b0a8707c&app_key=4b349db5bb77b9db"
```

## Usage

```shell
docker run --rm quay.io/3scale/perftest-toolkit:buddhi-v2-latest -h
usage: buddhi [options]
    -P, --portal    Admin portal endpoint
    -s, --services  3scale service list
    -o, --output    output file
    -h, --help
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
