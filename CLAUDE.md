# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains a Helm chart for deploying SearXNG, a privacy-respecting metasearch engine, to Kubernetes clusters. The project has two chart versions:

- `searxng/` - Main chart (version 1.0.1) using k8s-at-home common library
- `charts/searxng/` - Alternative chart (version 0.2.0) with updated dependencies

## Development Commands

### Helm Operations
```bash
# Lint the chart
helm lint searxng/

# Install locally for testing
helm install searxng searxng/ --dry-run --debug

# Package the chart
helm package searxng/

# Test with custom values
helm install searxng searxng/ -f custom-values.yaml --dry-run
```

### Chart Management
```bash
# Update dependencies
helm dependency update searxng/

# Build dependencies
helm dependency build searxng/
```

## Architecture

### Chart Structure
- **Main Chart**: `searxng/` contains the primary Helm chart with templates, values, and configuration
- **Alternative Chart**: `charts/searxng/` contains a simplified version with different dependency structure
- **Templates**: Standard Kubernetes resources (deployment, service, configmap, ingress)
- **Dependencies**: Uses common library charts for shared functionality and Redis for optional rate limiting

### Key Components
- **ConfigMap**: SearXNG settings are stored as base64-encoded YAML in a Kubernetes Secret
- **Dependencies**: 
  - k8s-at-home common library (v4.4.2) for shared chart patterns
  - Redis (optional, for rate limiting) from pascaliske.dev or bitnami
- **Configuration**: Primary config through `searxng.config` values, environment variables for runtime settings

### Chart Versioning
- Main chart uses semantic versioning (1.0.1)
- App version tracks SearXNG releases (latest tag)
- Dependencies are pinned to specific versions for stability

### Configuration Pattern
The chart uses a two-tier configuration approach:
1. Environment variables (`env.*`) for runtime settings like BASE_URL, INSTANCE_NAME
2. YAML configuration (`searxng.config`) for detailed SearXNG settings that get mounted as settings.yml

### Template Inheritance
Both charts follow different patterns:
- Main chart extends k8s-at-home common library for shared functionality
- Alternative chart uses more direct Kubernetes resource definitions