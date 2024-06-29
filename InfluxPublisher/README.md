# InfluxPublisher Reactors

This folder contains Lingua Franca reactors that publish to InfluxDB via a socket connection to Telegraf.

## How to use

1. Compile the LF example applications:

```bash
cd c && lfc src/InfluxPublisher.lf
cd py && lfc src/InfluxPublisher.lf
```

1. Start InfluxDB, Telegraf, Grafana and LF example applications:

```bash
docker compose up
```

Open Grafana on `http://0.0.0.0:3000` and open the dashboard Telegraf Test Publishers.
