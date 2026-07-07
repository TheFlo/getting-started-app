# Getting started

This repository is a sample application for users following the getting started guide at https://docs.docker.com/get-started/.

The application is based on the application from the getting started tutorial at https://github.com/docker/getting-started

## Monitoring

An optional monitoring stack (Prometheus, Grafana, Loki, Promtail, Jaeger) is available in `compose.monitoring.yaml` to demonstrate metrics, logs, and traces for this app. It's local/dev only — it is not deployed to the Azure VM and adds 5 extra containers (7 total), so it's heavier than the base tutorial.

The app exposes Prometheus metrics at `/metrics` and sends traces to Jaeger via OpenTelemetry auto-instrumentation (covering Express routes and MySQL queries). Logs stay on stdout and are scraped by Promtail directly from the Docker containers.

### Launching

The monitoring stack attaches to the `app-net` network created by the main app stack, so **start the app first**:

```bash
# 1. Start the app stack — creates the shared "app-net" network
docker compose up -d

# 2. Start the monitoring stack — attaches to the existing app-net network
docker compose -f compose.monitoring.yaml up -d
```

To stop, tear down in the reverse order (Docker refuses to remove a network that's still in use):

```bash
docker compose -f compose.monitoring.yaml down
docker compose down
```

> **Troubleshooting:** if you start `compose.monitoring.yaml` before `compose.yaml`, you'll see an error like `network app-net declared as external, but could not be found`. This is expected — it means `app-net` hasn't been created yet. Start the app stack first.

### URLs

| Tool         | URL                            | Notes                                                                       |
| ------------ | ------------------------------- | ---------------------------------------------------------------------------- |
| Grafana      | <http://localhost:3001>        | login `admin`/`admin`; Prometheus/Loki/Jaeger datasources and a sample dashboard are pre-provisioned |
| Prometheus   | <http://localhost:9090>        | scrape targets and raw metrics                                              |
| Jaeger UI    | <http://localhost:16686>       | search traces for service `todo-app`                                        |
| Loki         | <http://localhost:3100>        | headless API; browse logs via Grafana Explore                              |
| App metrics  | <http://localhost/metrics>     | raw Prometheus exposition format                                            |
