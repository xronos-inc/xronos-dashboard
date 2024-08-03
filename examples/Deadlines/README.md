# InfluxLinePublisher Reactors

This folder contains an example application involving deadline misses that can be visualized in the Lingua Franca tracing dashboard.

## How to use

1. Compile the LF example application:

   ```bash
   (cd c && lfc src/InfluxPublisher.lf)
   ```

1. Start Xronos Dashboard and LF example application:

   ```bash
   docker compose up
   ```

   Open Grafana on `http://localhost:3000` and open the dashboard "LF Tracing".
