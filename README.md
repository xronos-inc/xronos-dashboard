# Xronos Dashboard

Tracing and observability of Lingua Franca applications. Xronos Dashboard is built on top of the Xronos Trace Plugin, InfluxDB, Telegraf and Grafana.

## Features

- Xronos Lingua Franca Tracing
- InfluxDB v2
- Telegraf
- Grafana
- Test publisher in Python via HTTP
- Test publisher in C via UDP sockets

## How to use

Start the Xronos Dashboard:

```shell
docker compose up
```

InfluxDB, Telegraf and Grafana services will start.

### InfluxDB

- host: `http://localhost:8086`
- username: `admin`
- password: `linguafranca`

### Telegraf

- influx publishing (TCP): `http://localhost:8186/telegraf`
- influx publishing (UDP): `localhost:8094`

### Grafana

- host: `http://localhost:3000`
- username: `admin`
- password: `linguafranca`

## Publishers

Generic Lingua Franca reactors to publish to Xronos Dashboard are located in [InfluxPublisher/](InfluxPublisher/). Each language provides an `InfluxLinePublisher` reactor, and example applications to publish to the dashboard.

C: [InfluxPublisher/c](InfluxPublisher/c)

Python: [InfluxPublisher/py](InfluxPublisher/py)

See the [InfluxPublisher/README.md] to build and run the example publishers.

## User-Provided Dashboards

Grafana is configured by default to look for dashboards in the `/dashboards` path of the container. You can provide your own dashboards by mapping a folder from your host into this location.

## Production deployment

This reference repository is not meant for a production environment. If deploying onto public servers, create your own environment files with approprately stored passwords and map into the containers:

- `influxdb/influxdb.conf`
- `telegraf/telefraf.conf`
- `grafana/grafana.conf`
