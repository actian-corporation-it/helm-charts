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

### v3.6.0 (2023-08-03 - Suleyman Kutlu)

-----------------

#### Features

- Adding missing metrics required for Anodot

### v3.5.0 (2023-07-24 - Suleyman Kutlu)

-----------------

#### Features

- Adding cofiguration to scrape zookeeper

### v3.4.0 (2023-06-09 - Suleyman Kutlu)

-----------------

#### Bugfixes

- Grafana Agent was not able to scrape RabbitMQ detailed queue metrics consistently (COR-834)

### v3.3.0 (2023-25-09 - Suleyman Kutlu)

-----------------

#### Bugfixes

- Grafana Agent was not able to scrape spark-driver logs from Dataplane Clusters

#### Other changes

- Grafana Agwent version upgraded to v0.33.2

### v3.2.1 (2023-05-09 - Suleyman Kutlu)

-----------------

#### Bugfixes

- Grafana Agent v0.33.1 has binary in `/bin/grafana-agent`

### v3.2.0 (2023-05-09 - Suleyman Kutlu)

-----------------

#### Enhancements

- User / URL information is retrieved from Vault paramstore paths
  - ClusterSecretStore retrieves those information from Vault and sync to grafana-secret
  - Daemonset and Statefulset defines environment variables for those
  - Configmaps will use these environment variables where needed
- Grafana Agent version upgraded to v0.33.1

#### Bugfixes

- Vault paths for passwords updated

### v3.1.3 (2023-05-09 - Suleyman Kutlu)

-----------------

#### Bugfixes

- Istio Envoy Stats monitoring uses hard coded port number to scrape metrics. It should use the port defioned in pod annotations, instead.

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
- This version requires deletion of old grafana-agent deployment from clusters before deployment. This can be achieved via setting `global.deleteOldDeployment` value to `true` in environment or cluster configuration file for Harness pipeline automation

#### Features

- Use Consul Exporter integrated into Grafana Agent to scrape HashiCorp Consul metrics. This is compatible with the dashboard(s) and alerting provided by community mixin
- Use Redis iExporter integrated into Grafana Agent to scrape Redis metrics, if installed on cluster.  This is compatible with the dashboard(s) and alerting provided by community mixin

#### Enhancements

- Updates on ArgoCD scrape configurations - No need for static named deployments
- Add annotation for resources deployed via this Helm Chart to identify Helm Chart and Grafana Agent versions
- Simplify config map definitions for enhanced readability and reuseable definitions

