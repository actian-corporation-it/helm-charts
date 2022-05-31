# Helm Chart for Grafana Agent v0.1.0

Obtain following values for your Grafana Cloud organization / stack

- Prometheus Username / Instance ID
- Prometheus Remote Write Endpoint URL
- Loki Username / Instance ID
- Loki Push Endpoint URL
- A grafana.com API key with metric push privileges

Create custom values Yaml file to customize your deployment to include at minimum with the following:

```bash
metrics:
  prometheusId: <prometheus_id>
  prometheusPassword: <grafana_api_key>
  prometheusRemoteWriteUrl: <prometheus_endpoint_url>
  externalLabels:
    cloudProvider: "<cloud_provider>"
    cluster: "<k8s cluster name>"

logs:
  lokiId: <loki_id>
  lokiPassword: <grafana_api_key>
  lokiUrl: <loki_push_url>
  externalLabels:
    cloudProvider: "<cloud_provider>"
    cluster: "<k8s cluster name>"
```

To change namespace other than "monitoring" add following:
```bash
global:
  namespace: <k8s_namespace_name>
```

To deploy another version of grafana-agent other than default v0.24.2 add following:
```bash
global:
  agentVersion: <your_desired_version>
```

f node-exporter metrics are not needed, add following:
```bash
integrations:
  nodeExporter: false
```

Execute following to install the chart
```bash

$ helm install <release_name> ./grafana-agent -f <full_path_for_custom_values_yaml_file> --create-namespace

```

In order not to save secrets in a Yaml file, remove `prometheusPassword` and `lokiPassword` from custom values Yaml file and use environment variable instead:
```bash
$ GRAFANA_API_KEY=<grafana_api_key> helm install <release_name> ./grafana-agent -f <full_path_for_custom_values_yaml_file> --create-namespace \
  --set metrics.prometheusPassword=<grafana_api_key> \
  --set logs.lokiPassword=<grafana_api_key>
```

## Things To-Do
- Configuration for Tempo Distributed Tracing
- Parameterisation for scraping non-standard log files
- Alternative secrets management via Vault
