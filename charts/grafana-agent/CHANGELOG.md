# Changelog

This document contains a historical list of changes between releases. Only
changes that impact end-user behavior are listed; changes to documentation
are not present.

## Template


### v x.y.z (date - email of updater)

-----------------

#### Breaking changes

- Provide this block if applicable

#### Features

- Provide this block if applicable

#### Enhancements

- Provide this block if applicable

#### Bugfixes

- Provide this block if applicable

#### Other changes

- Provide this block if applicable

## Changes

### v3.1.2 (2023-04-04 - Suleyman Kutlu)

-----------------

#### Bugfixes

- Excessive if conditionals in helper template

### v3.1.1 (2023-04-04 - Suleyman Kutlu)

-----------------

#### Bugfixes

- Environment names in Harness CD cannot contain "-", environment name renamed to "cloudopsdev"

### v3.1.0 (2023-04-03 - Suleyman Kutlu)

-----------------

#### Features

- Added "cloudops-dev" as an accepted environment. This environment will send metrics / logs to grafana-dev deployment

### v3.0.1 (2023-03-20 - Suleyman Kutlu)

-----------------

#### Bugfixes

- ArgoCD namespaces list is provided as comma seperated string from the pipeline, we need to split it into an array before processing

### v3.0.0 (2023-03-10 - Suleyman Kutlu)

-----------------

#### Breaking changes

- Grafana-Agent version upgraded to v0.32.1
- Node Explorer configuration changed

#### Features

- Use Consul Exporter integrated into Grafana Agent to scrape HashiCorp Consul metrics. This is compatible with the dashboard(s) and alerting provided by community mixin
- Use Redis iExporter integrated into Grafana Agent to scrape Redis metrics, if installed on cluster.  This is compatible with the dashboard(s) and alerting provided by community mixin

#### Enhancements

- Updates on ArgoCD scrape configurations - No need for static named deployments
- Add annotation for resources deployed via this Helm Chart to identify Helm Chart and Grafana Agent versions
- Simplify config map definitions for enhanced readability and reuseable definitions

