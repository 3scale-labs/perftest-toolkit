#!/bin/env bash

echo "Cleaning tmp"
rm -rf /tmp/result.jtl
rm -rf /tmp/report

TARGET_PORT=${TARGET_PORT:-80}
PROTOCOL=${PROTOCOL:-http}
THREADS=${THREADS:-100}
DURATION=${DURATION:-600}

echo "Running Jmeter with: "
echo "port: $TARGET_PORT"
echo "Protocol: $PROTOCOL"
echo "rps: $RPS"
echo "Threads: $THREADS"
echo "Duration: $DURATION"

cd /opt/apache-jmeter-5.2/ || exit
./bin/jmeter.sh -n -t test-plan.jmx -Jtarget_port="$TARGET_PORT" \
                                    -Jprotocol="$PROTOCOL" \
                                    -Jthreads="$THREADS" \
                                    -Jrps="$RPS" \
                                    -Jduration="$DURATION" \
                                    -j /tmp/jmeter.log \
                                    -l /tmp/result.jtl \
                                    -e -o /tmp/report/
