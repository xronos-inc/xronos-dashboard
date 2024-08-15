# Xronos Dashboard

Tracing and observability of Lingua Franca applications. Xronos Dashboard is built on top of the Xronos Trace Plugin, InfluxDB, Telegraf and Grafana.

## Features

- Xronos Lingua Franca Tracing
- InfluxDB v2
- Telegraf
- Grafana
- Test publisher in Python via HTTP
- Test publisher in C via UDP sockets

## Running the Dashboard

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

## Using the Dashboard

### Lag

Lag is the time difference between the logical tag of events and the physical times at which they are handled. Lag captures how the physical timeline deviates logical timeline of the application. An application that is overloaded will typically exhibit growing lags. Lags in the order of seconds is unusual and likely indicates a fault.

There are two phenomena that contribute to lag: reaction execution time and (for federated applications) network communication time. Lag may be reduced by:

1. Adding logical delays on connections to account for execution time
2. Using physical actions to handle external or network events
3. Increasing `min_spacing` on actions or `period` on timers
4. Adding deadlines to reactions to discard old events

All of these make different trade-offs to handle execution time and communication latencies.

### Reaction Execution

Reaction Execution graphs are similar to Gantt charts. They visualize execution sequencing and time. The length of each bar represents the execution time of each reaction. The opacity of each bar represents the logical timeline of the reactor, with darker opacity corresponding with more recent logical timestamps (or microsteps).

## Generic Publishers

Generic Lingua Franca reactors to publish to Xronos Dashboard are located in [InfluxPublisher/](InfluxPublisher/). Each language provides an `InfluxLinePublisher` reactor, and example applications to publish to the dashboard.

C: [InfluxPublisher/c](InfluxPublisher/c/src/InfluxPublisher.lf)

Python: [InfluxPublisher/py](InfluxPublisher/py/src/InfluxPublisher.lf)

See [InfluxPublisher/README.md](InfluxPublisher/README.md) to build and run the example publishers.

## Examples

You can find additional examples in the [examples](examples/) directory.

## User-Provided Dashboards

Grafana is configured by default to look for dashboards in the `/dashboards` path of the container. You can provide your own dashboards by mapping a folder from your host into this location.

## Production deployment

This reference repository is not meant for a production environment. If deploying onto public servers, create your own environment files with approprately stored passwords and map into the containers:

- `influxdb/influxdb.conf`
- `telegraf/telefraf.conf`
- `grafana/grafana.conf`
