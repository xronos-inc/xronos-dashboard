# docker-compose Influx, Grafana and Telegraf

## Features

- InfluxDB v2
- Telegraf
- Grafana
- Test publisher in Python via HTTP
- Test publisher in C via UDP sockets
- Lingua Franca tracing

## How to use

```shell
docker compose up
```

The following services are available:

### Grafana

- host: `http://localhost:3000`
- username: `admin`
- password: `linguafranca`

### InfluxDB

- host: `http://localhost:8086`
- username: `admin`
- password: `linguafranca`

### Telegraf

- influx publishing (TCP): `http://localhost:8186/telegraf`
- influx publishing (UDP): `localhost:8094`

## User-Provided Dashboards

Grafana is configured by default to look for dashboards in the `/dashboards` path of the container. You can provide your own dashboards by mapping a folder from your host into this location.

## Production deployment

This reference repository is not meant for a production environment. If deploying onto public servers, create your own environment files with approprately stored passwords and map into the containers:

- `influxdb/influxdb.conf`
- `grafana/grafana.conf`
- `telegraf/telefraf.conf`