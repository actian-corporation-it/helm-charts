{{/*
*****************************************
Common service job helpers
*****************************************
*/}}
{{- define "metrics.metricRelabelDefaultConfigs" -}}
metric_relabel_configs:
- action: drop
  source_labels: [__name__]
  regex: go_.*
{{- end -}}

{{- define "metrics.metricRelabelConfigs" -}}
{{ include "metrics.metricRelabelDefaultConfigs" . }}
{{- if . -}}
{{- range . }}
- action: {{ .action }}
  source_labels: {{ .source_labels }}
  regex: {{ .regex }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
*****************************************
Statefulset Integration definitions
*****************************************
*/}}
{{- define "integrations.redisExporter" -}}
{{ printf "" }}
redis_configs:
{{- range $redisInstance := .Values.metrics.integrations.redis.instances -}}
{{- with $redisInstance -}}
{{- $redisTarget := (include "redis.target" . ) }}
- redis_addr: {{ $redisTarget }}
  instance: {{ .releaseName }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "integrations.hashicorpConsulExporter" -}}
{{- $hashicorpConsulTarget := (include "hashicorpConsul.target" .) }}
consul_configs:
- server: {{ $hashicorpConsulTarget }}
  instance: {{ .Values.metrics.integrations.hashicorpConsul.releaseName }}
{{- end -}}

{{- define "integrations.eventHandler" -}}
eventhandler:
  cache_path: "{{ .Values.global.agentVarDirectory }}/eventhandler/eventhandler.cache"
  logs_instance: {{ .Values.logs.eventHandlerInstanceName }}
{{- end -}}

{{/*
*****************************************
Statefulset service job definitions
*****************************************
*/}}
{{- define "statefulsetjobs.hashicorpVault" -}}
{{- $hashicorpVaultTarget := (include "hashicorpVault.target" .) }}
# Vault Server
- job_name: vault
  static_configs:
  - targets:
    - {{ $hashicorpVaultTarget }}
  metrics_path: /v1/sys/metrics
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.hashicorpVault | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.ingressNginx" -}}
{{- $ingressNginxTarget := (include "ingressNginx.target" .) }}
# NGINX Ingress Controller
- job_name: nginx-ingress
  static_configs:
  - targets:
    - {{ $ingressNginxTarget }}
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.ingressNginx | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.trivy" -}}
{{- $trivyTarget := (include "trivy.target" .) }}
# Trivy
- job_name: trivy
  static_configs:
  - targets:
    - {{ $trivyTarget }}
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.trivy | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.velero" -}}
{{- $veleroTarget := (include "velero.target" .) }}
# Velero
- job_name: velero
  static_configs:
  - targets:
    - {{ $veleroTarget }}
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.velero | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.certManager" -}}
{{- $certManagerTarget := (include "certManager.target" .) }}
# Cert-Manager
- job_name: cert-manager
  static_configs:
  - targets:
    - {{ $certManagerTarget }}
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.certManager | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.externalSecrets" -}}
{{- $externalSecretsTarget := (include "externalSecrets.target" .) }}
# External-Secrets-Operator
- job_name: external-secrets
  static_configs:
  - targets:
    - {{ $externalSecretsTarget }}
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.externalSecrets | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.rabbitmq" -}}
{{- $rabbitmqTarget := (include "rabbitmq.target" .) }}
{{- $rabbitmqTarget0 := (include "rabbitmq.target0" .) }}
{{- $rabbitmqTarget1 := (include "rabbitmq.target1" .) }}
{{- $rabbitmqTarget2 := (include "rabbitmq.target2" .) }}
# RabbitMQ
- job_name: rabbitmq-detailed-per-pod
  static_configs:
  - targets:
    - {{ $rabbitmqTarget0 }}
    - {{ $rabbitmqTarget1 }}
    - {{ $rabbitmqTarget2 }}
  metrics_path: /metrics/detailed
  params:
    family: 
      - queue_coarse_metrics
      - queue_consumer_count
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance

- job_name: rabbitmq
  static_configs:
  - targets:
    - {{ $rabbitmqTarget }}
  metrics_path: /metrics
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.rabbitmq | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.redpanda" -}}
{{- $redpandaTarget := (include "redpanda.target" .) }}
# RedPanda Kafka
- job_name: redpanda
  static_configs:
  - targets:
    - {{ $redpandaTarget }}
  metrics_path: /metrics
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.redpanda | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.zookeeper" -}}
{{- $zookeeperTarget := (include "zookeeper.target" .) }}
# Zookeeper
- job_name: zookeeper
  static_configs:
  - targets:
    - {{ $zookeeperTarget }}
  metrics_path: /metrics
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance

{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.zookeeper | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.mimir" -}}
# Mimir will be here soon
{{- end -}}

{{- define "statefulsetjobs.loki" -}}
# Loki will be here soon
{{- end -}}

{{- define "statefulsetjobs.grafana" -}}
# Grafana will be here soon
{{- end -}}

{{- define "statefulsetjobs.cadvisor" -}}
- job_name: cadvisor
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  kubernetes_sd_configs:
  - role: node
  relabel_configs:
  - replacement: kubernetes.default.svc:443
    target_label: __address__
  - regex: (.+)
    replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
    source_labels:
      - __meta_kubernetes_node_name
    target_label: __metrics_path__
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.cadvisor | indent 2 }}
  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: false
    server_name: kubernetes
{{- end -}}

{{- define "statefulsetjobs.kubelet" -}}
- job_name: kubelet
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  kubernetes_sd_configs:
  - role: node
  relabel_configs:
  - replacement: kubernetes.default.svc.cluster.local:443
    target_label: __address__
  - regex: (.+)
    replacement: /api/v1/nodes/$1/proxy/metrics
    source_labels:
      - __meta_kubernetes_node_name
    target_label: __metrics_path__
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.kubelet | indent 2 }}
  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: false
    server_name: kubernetes
{{- end -}}

{{- define "statefulsetjobs.kubeStateMetrics" -}}
# kube-state-metrics
- job_name: kube-state-metrics
  kubernetes_sd_configs:
  - role: service
  relabel_configs:
  - action: keep
    regex: kube-state-metrics
    source_labels:
      - __meta_kubernetes_service_name
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.kubeStateMetrics | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.argocd" -}}
{{- $root := . -}}
{{- $namespaces := split "," .Values.metrics.services.argocd.namespaces -}}
{{- range $argocdNamespace := $namespaces }}
# {{ $argocdNamespace }}
- job_name: {{ $argocdNamespace }}
  static_configs:
  - targets:
    - argocd-applicationset-controller.{{ $argocdNamespace }}.svc.cluster.local:8080
    - argocd-metrics.{{ $argocdNamespace }}.svc.cluster.local:8082
    - argocd-server-metrics.{{ $argocdNamespace }}.svc.cluster.local:8083
    - argocd-repo-server.{{ $argocdNamespace }}.svc.cluster.local:8084
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" $root.Values.metrics.filters.argocd | indent 2 }}
{{- end }}
{{- end -}}

{{- define "statefulsetjobs.istio" -}}
{{ printf "" }}
{{ include "statefulsetjobs.istioMesh" . }}
{{ include "statefulsetjobs.istioEnvoyStats" . }}
{{ include "statefulsetjobs.istioPolicy" . }}
{{ include "statefulsetjobs.istioTelemetry" . }}
{{ include "statefulsetjobs.istioPilot" . }}
{{ include "statefulsetjobs.istioGalley" . }}
{{ include "statefulsetjobs.istioCitadel" . }}
{{ include "statefulsetjobs.istioSidecarInjector" . }}
{{- end -}}

{{- define "statefulsetjobs.istioMesh" -}}
# istio-mesh
- job_name: 'istio-mesh'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - istio-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: istio-telemetry;prometheus
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioMesh | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.istioEnvoyStats" -}}
# envoy stats
- job_name: 'envoy-stats'
  metrics_path: /stats/prometheus
  kubernetes_sd_configs:
  - role: pod
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_container_port_name]
    action: keep
    regex: '.*-envoy-prom'
  - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
    action: replace
    regex: ([^:]+)(?::\d+)?;(\d+)
    replacement: $1:$2
    target_label: __address__
  - action: labeldrop
    regex: __meta_kubernetes_pod_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: namespace
  - source_labels: [__meta_kubernetes_pod_name]
    action: replace
    target_label: pod_name
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioEnvoyStats | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.istioPolicy" -}}
# istio-policy
- job_name: 'istio-policy'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - istio-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: istio-policy;http-policy-monitoring
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioPolicy | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.istioTelemetry" -}}
# istio-telemetry
- job_name: 'istio-telemetry'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - istio-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: istio-telemetry;http-monitoring
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioTelemetry | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.istioPilot" -}}
# istio-pilot
- job_name: 'istio-pilot'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - istio-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: istiod;http-monitoring
  - source_labels: [__meta_kubernetes_service_label_app]
    target_label: app
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioPilot | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.istioGalley" -}}
# istio-galley
- job_name: 'istio-galley'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - istio-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: istio-galley;http-monitoring
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioGalley | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.istioCitadel" -}}
# istio-citadel
- job_name: 'istio-citadel'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - istio-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: istio-citadel;http-monitoring
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioCitadel | indent 2 }}
{{- end -}}

{{- define "statefulsetjobs.istioSidecarInjector" -}}
# istio-sidecar-injector
- job_name: 'sidecar-injector'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - istio-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: istio-sidecar-injector;http-monitoring
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.istioSidecarInjector | indent 2 }}
{{- end -}}
