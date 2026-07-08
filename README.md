# Getting started

This repository is a sample application for users following the getting started guide at https://docs.docker.com/get-started/.

The application is based on the application from the getting started tutorial at https://github.com/docker/getting-started

## Monitoring

An optional monitoring stack (Prometheus, Grafana, Loki, Promtail, Jaeger) is available in `compose.monitoring.yaml` to demonstrate metrics, logs, and traces for this app. It adds 5 extra containers (7 total), so it's heavier than the base tutorial. It's also deployed to the Azure VM, fronted by an nginx reverse proxy (`compose.proxy.yaml`) so the tools are reachable over the already-open port 80 without opening extra ports in the NSG.

The app exposes Prometheus metrics at `/metrics` and sends traces to Jaeger via OpenTelemetry auto-instrumentation (covering Express routes and MySQL queries). Logs stay on stdout and are scraped by Promtail directly from the Docker containers.

### Launching

The monitoring and proxy stacks attach to the `app-net` network created by the main app stack, so **start the app first**:

```bash
# 1. Start the app stack — creates the shared "app-net" network
docker compose up -d

# 2. Start the monitoring stack — attaches to the existing app-net network
docker compose -f compose.monitoring.yaml up -d

# 3. Start the nginx reverse proxy — routes / to the app and /grafana/, /prometheus/, /jaeger/ to the tools
docker compose -f compose.proxy.yaml up -d
```

To stop, tear down in the reverse order (Docker refuses to remove a network that's still in use):

```bash
docker compose -f compose.proxy.yaml down
docker compose -f compose.monitoring.yaml down
docker compose down
```

> **Troubleshooting:** if you start `compose.monitoring.yaml` or `compose.proxy.yaml` before `compose.yaml`, you'll see an error like `network app-net declared as external, but could not be found`. This is expected — it means `app-net` hasn't been created yet. Start the app stack first.

On the Azure VM, `deploy-azure.yml` runs all three `docker compose` stacks automatically in this order on every deploy.

### URLs

Locally, each tool is still reachable directly on its own port:

| Tool | URL | Notes |
| --- | --- | --- |
| App | <http://localhost:3000> | direct container port (nginx also proxies it on port 80, see below) |
| Grafana | <http://localhost:3001> | login `admin`/`admin`; Prometheus/Loki/Jaeger datasources and a sample dashboard are pre-provisioned |
| Prometheus | <http://localhost:9090> | scrape targets and raw metrics |
| Jaeger UI | <http://localhost:16686> | search traces for service `todo-app` |
| Loki | <http://localhost:3100> | headless API; browse logs via Grafana Explore |

Through nginx (port 80, either locally or on the VM at `http://<vm-ip>/...`), everything is reachable path-based on a single port:

| Tool | URL |
| --- | --- |
| App | `http://<host>/` |
| App metrics | `http://<host>/metrics` |
| Grafana | `http://<host>/grafana/` |
| Prometheus | `http://<host>/prometheus/` |
| Jaeger UI | `http://<host>/jaeger/` |

No authentication is enforced on Prometheus/Grafana/Jaeger — treat this as a training/demo setup, not a hardened production one.
