# Changelog

This document contains a historical list of changes between releases. Only
changes that impact end-user behavior are listed; changes to documentation
are not present.

## Main (unreleased)

-----------------

### Features

- N/A

### Enhancements

- N/A

### Bugfixes

- N/A

### Other changes

- N/A

## v3.0.0 (2023-03-10 - Suleyman Kutlu)

-----------------

### Breaking changes

- Grafana-Agent version upgraded to v0.32.1
- Node Explorer configuration changed

### Features

- Use Consul Exporter integrated into Grafana Agent to scrape HashiCorp Consul metrics. This is compatible with the dashboard(s) and alerting provided by community mixin
- Use Redis iExporter integrated into Grafana Agent to scrape Redis metrics, if installed on cluster.  This is compatible with the dashboard(s) and alerting provided by community mixin

### Enhancements

- Updates on ArgoCD scrape configurations - No need for static named deployments
- Add annotation for resources deployed via this Helm Chart to identify Helm Chart and Grafana Agent versions
- Simplify config map definitions for enhanced readability and reuseable definitions

### Bugfixes

- N/A

### Other changes

- N/A

