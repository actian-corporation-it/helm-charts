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

{{- define "statefulsetjobs.hashicorpVault" -}}
{{- if .Values.metrics.services.hashicorpVault.enabled -}}
{{- $hashicorpVaultTarget := (include "hashicorpVault.target" .) -}}
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
{{- end -}}

{{- define "statefulsetjobs.hashicorpConsul" -}}
{{- if .Values.metrics.services.hashicorpConsul.enabled -}}
{{- $hashicorpConsulTarget := (include "hashicorpConsul.target" .) -}}
consul_configs:
- server: {{ $hashicorpConsulTarget }}
  instance: {{ .Values.metrics.services.hashicorpConsul.releaseName }}
{{- end -}}
{{- end -}}

{{- define "statefulsetjobs.ingressNginx" -}}
{{- if .Values.metrics.services.ingressNginx.enabled -}}
{{- $ingressNginxTarget := (include "ingressNginx.target" .) -}}
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
{{- end -}}

{{- define "statefulsetjobs.trivy" -}}
{{- if .Values.metrics.services.trivy.enabled -}}
{{- $trivyTarget := (include "trivy.target" .) -}}
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
{{- end -}}

{{- define "statefulsetjobs.velero" -}}
{{- if .Values.metrics.services.velero.enabled -}}
{{- $veleroTarget := (include "velero.target" .) -}}
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
{{- end -}}

{{- define "statefulsetjobs.certManager" -}}
{{- if .Values.metrics.services.certManager.enabled -}}
{{- $certManagerTarget := (include "certManager.target" .) -}}
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
{{- end -}}

{{- define "statefulsetjobs.externalSecrets" -}}
{{- if .Values.metrics.services.externalSecrets.enabled -}}
{{- $externalSecretsTarget := (include "externalSecrets.target" .) -}}
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
{{- end -}}

{{- define "statefulsetjobs.rabbitmq" -}}
{{- if .Values.metrics.services.rabbitmq.enabled -}}
{{- $rabbitmqTarget := (include "rabbitmq.target" .) -}}
# RabbitMQ
- job_name: rabbitmq
  static_configs:
  - targets:
    - {{ $rabbitmqTarget }}
  metrics_path: /metrics/per-object
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.rabbitmq | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "statefulsetjobs.redpanda" -}}
{{- if .Values.metrics.services.redpanda.enabled -}}
# RedPanda Kafka
- job_name: redpanda
  static_configs:
  - targets:
    - {{ .Values.metrics.services.redpanda.releaseName }}.{{ .Values.metrics.services.redpanda.namespace }}.svc.cluster.local:{{ .Values.metrics.services.redpanda.metricPort}}
  metrics_path: /metrics
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.redpanda | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "statefulsetjobs.mimir" -}}
{{- if and .Values.metrics.services.mimir .Values.metrics.services.mimir.enabled -}}
# Mimir will be here soon
{{- end -}}
{{- end -}}

{{- define "statefulsetjobs.loki" -}}
{{- if and .Values.metrics.services.loki .Values.metrics.services.loki.enabled -}}
# Loki will be here soon
{{- end -}}
{{- end -}}

{{- define "statefulsetjobs.grafana" -}}
{{- if and .Values.metrics.services.grafana .Values.metrics.services.grafana.enabled -}}
# Grafana will be here soon
{{- end -}}
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

{{- define "statefulsetjobs.argocdTemplate" -}}
{{- $root := .root -}}
{{- $env := .env -}}
{{- $jobName := printf "argocd-%s" $env -}}
# {{ $jobName }}
- job_name: {{ $jobName }}
  static_configs:
  - targets:
    - argocd-applicationset-controller.{{ $jobName }}.svc.cluster.local:8080
    - argocd-metrics.{{ $jobName }}.svc.cluster.local:8082
    - argocd-server-metrics.{{ $jobName }}.svc.cluster.local:8083
    - argocd-repo-server.{{ $jobName }}.svc.cluster.local:8084
  relabel_configs:
  - source_labels: [__address__]
    target_label: __param_target
    regex: ([\w\-\_]+)\..+:\d+
  - source_labels: [__param_target]
    target_label: instance
{{- end -}}

{{- define "statefulsetjobs.argocd" -}}
{{- if .Values.metrics.services.argocdDev.enabled -}}
{{ include "statefulsetjobs.argocdTemplate" (dict "root" . "env" "dev") }}
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.argocdDev | indent 2 }}
{{- end }}
{{- if .Values.metrics.services.argocdTest.enabled }}
{{ include "statefulsetjobs.argocdTemplate" (dict "root" . "env" "test") }}
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.argocdTest | indent 2 }}
{{- end }}
{{- if .Values.metrics.services.argocdStage.enabled }}
{{ include "statefulsetjobs.argocdTemplate" (dict "root" . "env" "stage") }}
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.argocdStage | indent 2 }}
{{- end }}
{{- if .Values.metrics.services.argocdProduction.enabled }}
{{ include "statefulsetjobs.argocdTemplate" (dict "root" . "env" "production") }}
{{ include "metrics.metricRelabelConfigs" .Values.metrics.filters.argocdProduction | indent 2 }}
{{- end }}
{{- end -}}

{{- define "statefulsetjobs.istio" -}}
{{- if .Values.metrics.services.istio.enabled -}}
{{ include "statefulsetjobs.istioMesh" . }}
{{ include "statefulsetjobs.istioEnvoyStats" . }}
{{ include "statefulsetjobs.istioPolicy" . }}
{{ include "statefulsetjobs.istioTelemetry" . }}
{{ include "statefulsetjobs.istioPilot" . }}
{{ include "statefulsetjobs.istioGalley" . }}
{{ include "statefulsetjobs.istioCitadel" . }}
{{ include "statefulsetjobs.istioSidecarInjector" . }}
{{- end -}}
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
    replacement: $1:15090
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
