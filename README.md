# SearXNG Helm Charts

[![Release Charts](https://github.com/searxng/searxng-helm-chart/actions/workflows/release.yml/badge.svg)](https://github.com/searxng/searxng-helm-chart/actions/workflows/release.yml)

This repository contains Helm charts for deploying [SearXNG](https://github.com/searxng/searxng), a privacy-respecting, hackable metasearch engine.

## Usage

[Helm](https://helm.sh) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add searxng https://searxng.github.io/searxng-helm-chart
helm repo update
```

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages.

You can then run `helm search repo searxng` to see the charts.

## Installing the Chart

To install the chart with the release name `my-searxng`:

```bash
helm install my-searxng searxng/searxng
```

To install the chart with custom values:

```bash
helm install my-searxng searxng/searxng -f my-values.yaml
```

## Uninstalling the Chart

To uninstall the `my-searxng` deployment:

```bash
helm uninstall my-searxng
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the SearXNG chart and their default values.

### Basic Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `replicaCount` | int | `1` | Number of replicas |
| `image.repository` | string | `"searxng/searxng"` | SearXNG image repository |
| `image.pullPolicy` | string | `"IfNotPresent"` | Image pull policy |
| `image.tag` | string | `""` | Overrides the image tag whose default is the chart appVersion |

### Service Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `service.type` | string | `"ClusterIP"` | Service type |
| `service.port` | int | `8080` | Service port |
| `service.targetPort` | int | `8080` | Target port on the pod |

### Ingress Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `ingress.enabled` | bool | `false` | Enable ingress |
| `ingress.className` | string | `""` | Ingress class name |
| `ingress.hosts[0].host` | string | `"searxng.local"` | Hostname for the ingress |
| `ingress.hosts[0].paths[0].path` | string | `"/"` | Path for the ingress |
| `ingress.hosts[0].paths[0].pathType` | string | `"Prefix"` | Path type for the ingress |

### Environment Variables

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `env.INSTANCE_NAME` | string | `"SearXNG"` | Instance name displayed in the interface |
| `env.BASE_URL` | string | `"http://localhost:8080/"` | Base URL for the instance |
| `env.AUTOCOMPLETE` | string | `"false"` | Enable autocomplete |

### Resources

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `resources.limits.cpu` | string | `"500m"` | CPU limit |
| `resources.limits.memory` | string | `"512Mi"` | Memory limit |
| `resources.requests.cpu` | string | `"100m"` | CPU request |
| `resources.requests.memory` | string | `"256Mi"` | Memory request |

### Redis Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `redis.enabled` | bool | `false` | Enable Redis deployment for rate limiting |
| `redis.architecture` | string | `"standalone"` | Redis architecture |
| `redis.auth.enabled` | bool | `false` | Enable Redis authentication |

### Security

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `podSecurityContext.fsGroup` | int | `977` | Pod security context fsGroup |
| `securityContext.runAsNonRoot` | bool | `true` | Run as non-root user |
| `securityContext.runAsUser` | int | `977` | User ID to run the container |
| `securityContext.runAsGroup` | int | `977` | Group ID to run the container |
| `securityContext.readOnlyRootFilesystem` | bool | `true` | Use read-only root filesystem |

### Monitoring

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `serviceMonitor.enabled` | bool | `false` | Enable ServiceMonitor for Prometheus |
| `serviceMonitor.interval` | string | `"30s"` | Scrape interval |
| `serviceMonitor.path` | string | `"/stats/errors"` | Metrics path |

## Examples

### Basic Installation

```bash
helm install searxng searxng/searxng
```

### With Ingress

```yaml
# values.yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: search.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: searxng-tls
      hosts:
        - search.example.com

env:
  BASE_URL: "https://search.example.com/"
  INSTANCE_NAME: "My SearXNG Instance"
```

```bash
helm install searxng searxng/searxng -f values.yaml
```

### With Redis for Rate Limiting

```yaml
# values.yaml
redis:
  enabled: true
  auth:
    enabled: true
    password: "myredispassword"

searxng:
  config:
    server:
      limiter: true
    redis:
      url: "redis://:myredispassword@searxng-redis-master:6379/0"
```

```bash
helm install searxng searxng/searxng -f values.yaml
```

### Production Configuration

```yaml
# values.yaml
replicaCount: 3

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 512Mi

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: search.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: searxng-tls
      hosts:
        - search.example.com

redis:
  enabled: true
  auth:
    enabled: true
  master:
    persistence:
      enabled: true
      size: 2Gi

env:
  BASE_URL: "https://search.example.com/"
  INSTANCE_NAME: "Production SearXNG"

searxng:
  config:
    server:
      limiter: true
      secret_key: "your-secret-key-here"
    redis:
      url: "redis://:password@searxng-redis-master:6379/0"

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

podDisruptionBudget:
  enabled: true
  minAvailable: 2
```

```bash
helm install searxng searxng/searxng -f values.yaml
```

## Development

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) 3.8+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured to connect to your cluster

### Linting

```bash
helm lint charts/searxng/
```

### Testing

```bash
helm install --dry-run --debug searxng charts/searxng/
```

### Package

```bash
helm package charts/searxng/
```

## Contributing

Contributions are welcome! Please read the contributing guidelines and submit pull requests to the [GitHub repository](https://github.com/searxng/searxng-helm-chart).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- [SearXNG Documentation](https://docs.searxng.org/)
- [SearXNG GitHub Repository](https://github.com/searxng/searxng)
- [Helm Chart Issues](https://github.com/searxng/searxng-helm-chart/issues)