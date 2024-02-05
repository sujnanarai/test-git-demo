#!/usr/bin/env bash

DOCKERCOMPOSEFILE="/home/ubuntu/$KONG_COURSE_ID/installation/docker-compose.yaml"
export KONG_LICENSE_DATA=$(cat /etc/kong/license.json) # not used here but later when we restart the cp

yq -i '.services.kong-cp.environment.KONG_VITALS_STRATEGY = "prometheus"' $DOCKERCOMPOSEFILE
yq -i '.services.kong-cp.environment.KONG_VITALS_STATSD_ADDRESS = "statsd:9125"' $DOCKERCOMPOSEFILE
yq -i '.services.kong-cp.environment.KONG_VITALS_TSDB_ADDRESS = "prometheus:9090"' $DOCKERCOMPOSEFILE

yq -i '.services.kong-dp.environment.KONG_VITALS_STRATEGY = "prometheus"' $DOCKERCOMPOSEFILE
yq -i '.services.kong-dp.environment.KONG_VITALS_STATSD_ADDRESS = "statsd:9125"' $DOCKERCOMPOSEFILE
yq -i '.services.kong-dp.environment.KONG_VITALS_TSDB_ADDRESS = "prometheus:9090"' $DOCKERCOMPOSEFILE
