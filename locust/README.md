# Locust

If you’re running into memory/garbage collection issues with hyperfoil that are preventing a full run on the `standard` [profile](https://github.com/3scale-labs/perftest-toolkit/blob/main/buddhi/README.md#profiles) then try using locust to run the actual performance test.

**NOTE:** The files in this directory (except for this README) were copied from the [3scale-2.15-injector branch](https://github.com/integr8ly/locust-integreatly-operator/tree/3scale-2.15-injector) in the [integr8ly/locust-integreatly-operator](https://github.com/integr8ly/locust-integreatly-operator) project.

## Prerequisites
* Successfully ran the [injector](https://github.com/3scale-labs/perftest-toolkit/tree/main?tab=readme-ov-file#deploy-injector) to generate the `3scale.csv` traffic file (the ansible playbook will automatically copy the file to this directory)
* Installed the Locust CLI - installation instructions can be found [here](https://docs.locust.io/en/stable/installation.html)

## Run tests
**1.** From the `locust` directory start locust.
```bash
./start.sh
```

**NOTE:** If locust is complaining about the port `8089` being blocked, try specifying a different port in [start.sh](start.sh) using the `--web-port` flag like this:
```
cores=$(grep -c ^processor /proc/cpuinfo)
ulimit -n 10000

echo "starting locust master"
locust --master --web-port 8888 &

echo "creating worker nodes for other cores"
for (( c=2; c<=cores; c++ ))
do
  echo "starting locust worker"
  locust --worker --web-port 8888 &
done
```

**2.** Access the locust UI in your browser at http://localhost:8089/ (make sure to specify the correct port if you changed it above).

**3.** Set the `Number of users` and `Ramp up` but clear the `Host` field  since the host will be randomly fetched from the CSV traffic file. You can let the test run indefinitely or specify the `Run time` in the Advanced options drop down menu.

**4.** When the run is complete you can download the load test report from the `DOWNLOAD DATA` tab.

**5.** After saving the results, you can shut down the workers by running the kill script.
```bash
./kill.sh
```