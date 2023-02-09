# Helm Chart for K6 Synthetic Monitors

This Helm Chart deploys K6 Synthetic Tests to run on Kubernetes K6 Operator

- Deploys the manifest to run the test
- Deploys cronjobs to schedule them periodically
- Creates required External Secret Stores based on provided values

Until integrated into a Harness Pipeline, create a custom values Yaml file to customize your deployment for K8s cluster as sample below:

```bash
$ cat k6-use2-dev_values_override.yaml
clusterName: k6-use2-dev
environment: dev
grafanaRegion: us
k6Image:
  name: actian/k6-actian-cloudops
  tag: 0.4.0
grafanaParameters:
  prometheusUrl:
    remoteKey: paramstore/dev/us
    remoteProperty: mimir_remote_write_url
  prometheusUsername:
    remoteKey: paramstore/dev/us
    remoteProperty: mimir_user
  prometheusPassword:
    remoteKey: grafana_oss_passwords/dev
    remoteProperty: mimir_password
syntheticTests:
  definitions:
    avalanche-login:
      usernameSecretKey: av_console_username
      usernameRemoteKey: synthetics/production/avalanche-login
      passwordSecretKey: av_console_password
      passwordRemoteKey: synthetics/production/avalanche-login
    integrationmanager-login:
      usernameSecretKey: im_console_username
      usernameRemoteKey: synthetics/production/integrationmanager-console-login
      passwordSecretKey: im_console_password
      passwordRemoteKey: synthetics/production/integrationmanager-console-login
```

## Sample deployment

Execute following to install the chart

```bash
helm upgrade --install --kube-context k6-use2-dev k6-synthetic-tests cloudops/k6-synthetic-tests --namespace k6-synthetic-tests --create-namespace --values k6-use2-dev_values_override.yaml
```

## Things To-Do

- Configuration Harness to deploy
