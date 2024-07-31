# InfluxLinePublisher Reactors

This folder contains Lingua Franca reactors that publish to InfluxDB via a socket connection to Telegraf, and example applications that publish to the Xronos Dashboard.

## How to use

1. Compile the LF example applications:

   ```bash
   cd c && lfc src/CInfluxPublisher.lf; cd ..
   cd py && lfc src/PyInfluxPublisher.lf; cd ..
   ```

1. Start Xronos Dashboard and LF example applications:

   ```bash
   docker compose up
   ```

   Open Grafana on `http://0.0.0.0:3000` and open the dashboard "Telegraf Test Publishers".
