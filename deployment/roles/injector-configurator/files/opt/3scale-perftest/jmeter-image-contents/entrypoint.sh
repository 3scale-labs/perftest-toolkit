#!/bin/env bash

echo "Cleaning tmp"
rm -rf /tmp/result.jtl
rm -rf /tmp/report

TARGET=${TARGET}
TARGET_PORT=${TARGET_PORT:-80}
PROTOCOL=${PROTOCOL:-http}
TARGET_PATH=${TARGET_PATH:-/}
THREADS=${THREADS:-100}
DURATION=${DURATION:-600}

echo "Running Jmeter with: "
echo "Target: $TARGET"
echo "Target Host Header: $TARGET_HOST_HEADER"
echo "Target port: $TARGET_PORT"
echo "Protocol: $PROTOCOL"
echo "Path: $TARGET_PATH"
echo "rps: $RPS"
echo "Threads: $THREADS"
echo "Duration: $DURATION"

cd /opt/apache-jmeter-3.1/ || exit
./bin/jmeter.sh -n -t test-plan.jmx -Jtarget="$TARGET" \
                                    -Jtarget_port="$TARGET_PORT" \
                                    -Jprotocol="$PROTOCOL" \
                                    -Jpath="$TARGET_PATH" \
                                    -Jthreads="$THREADS" \
                                    -Jrps="$RPS" \
                                    -Jduration="$DURATION" \
                                    -Jtarget_host_header="$TARGET_HOST_HEADER" \
                                    -j /tmp/jmeter.log \
                                    -l /tmp/result.jtl \
                                    -e -o /tmp/report/
