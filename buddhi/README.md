# Buddhi - 3scale traffic file generation tool

Responsibilities:

* Generate CSV formatted file with **Host, Path** columns.
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
docker run --rm quay.io/3scale/perftest-toolkit:v2.2.2 -h
usage: buddhi [options]
    -P, --portal    Admin portal endpoint
    -s, --services  3scale service list
    -e, --endpoint  API upstream endpoint
    -p, --profile   3scale product profile. Valid profiles ["simple", "backend", "standard"]
    -o, --output    output file
    -h, --help
    -v, --version   print the version
```

`--services` and `--profile` are mutually exclusive options.

* If `--services` is provided, the tool will inspect those services and generate traffic tool from them.
* If `--profile` is provided, the tool will create a 3scale product with the given profile. Currently valid profiles are `simple, backend, standard`. `--profile` option requires `--endpoint` option to be provided.

### Profiles

* The **simple** profile defines:
  * One product
    * One mapping rule (for hits metric)
    * One application plan
    * One application plan limit (big enough to not be reached)
    * One application
  * One backend 
* The **backend** profile defines: 
  * One product
    * One application plan
    * One application plan limit (big enough to not be reached)
    * One application
  * One backend 
    * One method
    * One mapping rule (for the previous method)
* The **standard** profile defines: 
  * 1 Account
    * 10000 Applications
  * 100 products
    * 1 application plan per product
    * 10 application plan limits per product
    * 100 application per plan
    * 10 backend usages per product
  * 1000 backend (each product will be using 10 backends)
    * 50 methods
    * 50 mapping rules

## Development

## Build docker image

```shell
make clean
make build'
```

## Releasing

```shell
make push
```
