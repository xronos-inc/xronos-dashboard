#!/bin/bash

set -x

docker compose down
docker compose rm
docker volume rm xronos-dashboard_influxdb-data
docker volume rm xronos-dashboard_grafana-data

if [ -f influxdb/config/influx-configs ]; then
    echo influxdb/config/influx-configs present and is not deleted by this script
fi
