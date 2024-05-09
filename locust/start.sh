cores=$(grep -c ^processor /proc/cpuinfo)
ulimit -n 10000

echo "starting locust master"
locust --master &

echo "creating worker nodes for other cores"
for (( c=2; c<=cores; c++ ))
do
  echo "starting locust worker"
  locust --worker &
done