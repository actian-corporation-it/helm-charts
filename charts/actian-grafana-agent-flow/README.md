# Helm Chart for Grafana Agent Flow Mode

This Helm Chart deploys official [Grafana Agent Helm Chart](https://github.com/grafana/agent/tree/main/operations/helm/charts/grafana-agent) with Actian specific configuration items such as:

- External Secrets Operator components to retrieve Grafana Secrets from Vault
- Configmap for River Modules used by Grafana Agent Flow mode
