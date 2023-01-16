# Helm Chart for Grafana Agent
Currently this Helm Chart deploys Grafana Agent with following options:

- Metrics scraping
- Kubernetes Cluster level metrics (kubelet, cadvisor, kube state metrics)
- POD / Node level (kubernetes_pods, kuberneted, node_exporter)
- Log scraping
- POD level logse
- RabbitMQ metrics scraping

All the above can be turned on or off with values override during deployment time. List of all values and their default values are below:

**NOTE:** For `kube-state-metrics` integration to work, it should be deployed in the cluster. If not yet, it can be deployed with:
```bash
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
$ helm install kube-state-metrics prometheus-community/kube-state-metrics --namespace kube-system
```

|     |     |     |
| --- | --- | --- |
| **Variable name** | **Description** | **Default value** |
| global.agentVersion | Grafana agent version. If equals to ““ then Charts.AppVersion is used. | ““  |
| global.namespace | Namespace to install Grafana agent | monitoring |
| global.timeZone | Timezone definition for Grafana agent statefulset and daemonset. If equals to ““ then it defaults to UTC | ““  |
| global.externalLabels.cloudProvider | External label “cloudProvider” to add to all metrics / logs scraped. Values can be:<br><br>*   gcp<br>    <br>*   aws<br>    <br>*   azure | ““  |
| global.externalLabels.cluster | External label “cluster” to add to all metrics / logs scraped. Value is unique cluster name | ““  |
|     | These two external metrics are mandatory. More can be added as required. |     |
| daemonset.createServiceAccount | If true, a service account is created for Grafana agent daemonset | true |
| daemonset.serviceAccountName | If set to ““ then service account name is derived from Chart release name<br><br>If service account name for both daemonset and statefulset have the same (derived) value, only one is created. | ““  |
| daemonset.serverPort | Grafana agent daemonset server port to listen | 13579 |
| daemonset.logLevel | Grafana agent daemonset logging level | info |
| statefulset.createServiceAccount | If true, a service account is created for Grafana agent statefulset | true |
| statefulset.serviceAccountName | If set to ““ then service account name is derived from Chart release name<br><br>If service account name for both daemonset and statefulset have the same (derived) value, only one is created. | ““  |
| statefulset.serverPort | Grafana agent statefulset server port to listen | 13578 |
| statefulset.logLevel | Grafana agent statefulset logging level | info |
| metrics.enabled | If set to true, metrics scraping is configured in daemonset and statefulset | true |
| metrics.scrapeInterval | Metric scraping interval | 30s |
| metrics.prometheusId | Grafana Cloud Prometheus ID/Username | 0   |
| metrics.prometheusPassword | Grafana Cloud API key with MetricPublisher permissions | PaSsW0Rd |
| metrics.prometheusRemoteWriteUrl | Grafana Cloud Prometheus Remote Write Endpoint URL | [https://127.0.0.1](https://127.0.0.1) |
| metrics.integrations.cadvisor.enabled | If set to true, cadvisor metrics are scraped | true |
| metrics.integrations.nodeExporter.enabled | If set to true, node\_exporter that is integrated to Grafana agent is enabled in Grafana agent daemonsets. This will lead to scrape node metrics from each node. | true |
| metrics.integrations.nodeExporter.collectorSet | Set of node\_exporter collectors to be enabled. | cpu, filesystem, loadvg, meminfo, netstat |
| metrics.integrations.kubeStateMetrics.enabled | If set to true, Kube State Metrics are scraped | true |
| metrics.integrations.rabbitmq.enabled | If set to true, RabbitMQ metrics scraping will be configured in Grafana agent statefulset<br><br>In order to monitor RabbitMQ, RabbitMQ Helm Chart should be deployed with “metrics.enabled=true”. This will enable Prometheus exporter in RabbitMQ deployment. The hostname for RabbitMQ statefulset is derived from RabbitMQ release name and namespace as below:<br><br>“<release\_name>.<namespace>.svc.cluster.local:<exporter\_port>” | false |
| metrics.integrations.rabbitmq.releaseName | Release name of RabbitMQ in cluster | my-release |
| metrics.integrations.rabbitmq.namespace | Namespace where RabbitMQ is deployed | default |
| metrics.integrations.rabbitmq.metricPort | TCP Port where RabbitMQ Prometheus metrics are exported | 9419 |
| metrics.filters.nodeExporter | "metrics_relabel_configs" details for node\_exporter. It should be in the format of Prometheus [`metrics_relabel_configs`](https://prometheus.io/docs/prometheus/2.34/configuration/configuration/#relabel_config) | Check `values.yaml` for default set |
| metrics.filters.kubelet | "metrics_relabel_configs" details for kubelet. It should be in the format of Prometheus [`metrics_relabel_configs`](https://prometheus.io/docs/prometheus/2.34/configuration/configuration/#relabel_config) | Check `values.yaml` for default set |
| metrics.filters.kubeStateMetrics | "metrics_relabel_configs" details for kube_state_metrics. It should be in the format of Prometheus [`metrics_relabel_configs`](https://prometheus.io/docs/prometheus/2.34/configuration/configuration/#relabel_config) | Check `values.yaml` for default set |
| metrics.filters.cadvisor | "metrics_relabel_configs" details for cadvisor. It should be in the format of Prometheus [`metrics_relabel_configs`](https://prometheus.io/docs/prometheus/2.34/configuration/configuration/#relabel_config) | Check `values.yaml` for default set |
| logs.enabled | If set to true, metrics scraping is configured in daemonset and statefulset | true |
| logs.lokiId | Grafana Cloud Loki ID/Username | 0   |
| logs.lokiPassword | Grafana Cloud API key with MetricPublisher permissions | PaSsW0Rd |
| logs.lokiUrl | Grafana Cloud Loki Endpoint URL | [https://127.0.0.1](https://127.0.0.1) |
| logs.defaultPipelineStage | Log parsing parameter for Loki | docker |
| logs.jobs | Additional log parsing jobs can be added here (experimental, details will be documented later) | {}  |
## Values override preperations
Obtain following values for your Grafana Cloud organization / stack

- Prometheus Username / Instance ID
- Prometheus Remote Write Endpoint URL
- Loki Username / Instance ID
- Loki Push Endpoint URL
- A grafana.com API key with metric push privileges

Create custom values Yaml file to customize your deployment to include at minimum with the following:

```bash
global:
  externalLabels:
    cloudProvider: "aws"
    cluster: "tools-test"

metrics:
  prometheusId: <prometheus_id>
  prometheusPassword: <grafana_api_key>
  prometheusRemoteWriteUrl: <prometheus_endpoint_url>
  integrations:
    cadvisor:
      enabled: true

logs:
  lokiId: <loki_id>
  lokiPassword: <grafana_api_key>
  lokiUrl: <loki_push_url>
```

To change namespace other than "monitoring" add following to custom values file and correct value for `--namespace` option in Helm CLI:
```bash
global:
  namespace: <k8s_namespace_name>
```

To deploy another version of grafana-agent other than default:
```bash
global:
  agentVersion: <your_desired_version>
```

If node-exporter metrics are not needed, add following:
```bash
integrations:
  nodeExporter: false
```
## Sample deployment
Execute following to install the chart
```bash

$ helm install <release_name> ./grafana-agent -f <full_path_for_custom_values_yaml_file> --namespace monitoring --create-namespace

```

If you don't want to store secrets in a Yaml file, remove `prometheusPassword` and `lokiPassword` from custom values Yaml file and use environment variable instead:
```bash
$ GRAFANA_API_KEY=<grafana_api_key> helm install <release_name> ./grafana-agent -f <full_path_for_custom_values_yaml_file> --create-namespace \
  --set metrics.prometheusPassword=$GRAFANA_API_KEY \
  --set logs.lokiPassword=$GRAFANA_API_KEY
```

## Things To-Do
- Configuration for Tempo Distributed Tracing
- Parameterisation for scraping non-standard log files
- Alternative secrets management via Vault / External Secret Manager
