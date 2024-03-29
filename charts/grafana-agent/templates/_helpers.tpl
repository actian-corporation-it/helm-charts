{{/*
*****************************************
Authentication blocks
*****************************************
*/}}
{{- define "prometheus.authentication" -}}
{{- $prometheusRemoteWriteUrl := (include "urls.prometheusRemoteWriteUrl" .) -}}
{{- $prometheusId := (include "credentials.prometheusId" .) -}}
{{- $prometheusPassword := (include "credentials.prometheusPassword" .) -}}
remote_write:
- url: {{ $prometheusRemoteWriteUrl }}
  {{- if eq .Values.global.environment "cloudopsdev" }}
  headers:
    X-Scope-OrgId: cloudopsdev
  {{- else if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") }}
  headers:
    X-Scope-OrgId: engineering
  {{- else if eq .Values.global.environment "stage" }}
  headers:
    X-Scope-OrgId: stage
  {{- end }}
  basic_auth:
    username: {{ $prometheusId }}
    password: {{ $prometheusPassword }}
{{- end -}}

{{- define "loki.authentication" -}}
{{- $lokiUrl := (include "urls.lokiUrl" .) -}}
{{- $lokiId := (include "credentials.lokiId" .) -}}
{{- $lokiPassword := (include "credentials.lokiPassword" .) -}}
clients:
- url: {{ $lokiUrl }}
  {{- if eq .Values.global.environment "cloudopsdev" }}
  tenant_id: cloudopsdev
  {{- else if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test")  }}
  tenant_id: engineering
  {{- else if eq .Values.global.environment "stage" }}
  tenant_id: stage
  {{- end }}
  basic_auth:
    username: {{ $lokiId }}
    password: {{ $lokiPassword }}
{{- end -}}

{{/*
*****************************************
Misc definitions
*****************************************
*/}}

{{- define "annotations.versions" -}}
{{- $grafanaAgentVersion := (include "grafanaAgent.Version" .) -}}
grafana_agent_versions: "Chart: {{ $.Chart.Name }} / {{ $.Chart.Version }}; App: {{ $grafanaAgentVersion }}"
{{- end -}}

{{- define "statefulset.ServiceName" -}}
  {{- printf "%s-statefulset" .Release.Name -}}
{{- end -}}

{{- define "daemonset.ServiceName" -}}
  {{- printf "%s-daemonset" .Release.Name -}}
{{- end -}}

{{- define "statefulset.ConfigMapName" -}}
  {{- printf "%s-statefulset" .Release.Name -}}
{{- end -}}

{{- define "daemonset.ConfigMapName" -}}
  {{- printf "%s-daemonset" .Release.Name -}}
{{- end -}}

{{- define "grafanaAgent.Version" -}}
  {{- if eq .Values.global.agentVersion "" -}}
    {{- printf "%s" $.Chart.AppVersion -}}
  {{- else -}}
    {{- printf "%s" .Values.global.agentVersion -}}
  {{- end -}}
{{- end -}}

{{/*
*****************************************
Agent Configuration definitions
*****************************************
*/}}
{{- define "agentConfig.externalLabels" -}}
external_labels:
  {{- range $key, $value := $.Values.global.externalLabels }}
    {{- if $value }}
  {{ $key }}: {{ $value }}
    {{- else }}
      {{ required (printf "\n\nMissing value: A value is required for metrics label %s\n" $key) nil }}
    {{- end }}
  {{- end }}
{{- end -}}

{{- define "agentConfig.daemonsetServer" -}}
server:
  log_format: {{ .Values.daemonset.logFormat }}
  log_level: {{ .Values.daemonset.logLevel }}
{{- end -}}

{{- define "agentConfig.statefulsetServer" -}}
server:
  log_format: {{ .Values.statefulset.logFormat }}
  log_level: {{ .Values.statefulset.logLevel }}
{{- end -}}

{{/*
*****************************************
Common Integration definitions
*****************************************
*/}}
{{- define "integrations.metrics" -}}
metrics:
  autoscrape:
    enable: true
    metrics_instance: {{ .Values.metrics.instanceName }}
{{- end -}}

{{/*
*****************************************
Application target definitions
*****************************************
*/}}
{{- define "redpanda.target" -}}
  {{- $port := .Values.metrics.services.redpanda.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.redpanda.releaseName .Values.metrics.services.redpanda.namespace $port -}}
{{- end -}}

{{- define "rabbitmq.target" -}}
  {{- $port := .Values.metrics.services.rabbitmq.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.namespace $port -}}
{{- end -}}

{{- define "rabbitmq.target0" -}}
  {{- $port := .Values.metrics.services.rabbitmq.metricPort | toString -}}
  {{- printf "%s-0.%s-headless.%s.svc.cluster.local:%s" .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.namespace $port -}}
{{- end -}}

{{- define "rabbitmq.target1" -}}
  {{- $port := .Values.metrics.services.rabbitmq.metricPort | toString -}}
  {{- printf "%s-1.%s-headless.%s.svc.cluster.local:%s" .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.namespace $port -}}
{{- end -}}

{{- define "rabbitmq.target2" -}}
  {{- $port := .Values.metrics.services.rabbitmq.metricPort | toString -}}
  {{- printf "%s-2.%s-headless.%s.svc.cluster.local:%s" .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.namespace $port -}}
{{- end -}}

{{- define "zookeeper.target" -}}
  {{- $port := .Values.metrics.services.zookeeper.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.zookeeper.releaseName .Values.metrics.services.zookeeper.namespace $port -}}
{{- end -}}

{{- define "externalSecrets.target" -}}
  {{- $port := .Values.metrics.services.externalSecrets.metricPort | toString -}}
  {{- printf "%s-metrics.%s.svc.cluster.local:%s" .Values.metrics.services.externalSecrets.releaseName .Values.metrics.services.externalSecrets.namespace $port -}}
{{- end -}}

{{- define "argocd.target" -}}
  {{- $port := .Values.metrics.services.argocd.metricPort | toString -}}
  {{- printf "%s-metrics.%s.svc.cluster.local:%s" .Values.metrics.services.argocd.releaseName .Values.metrics.services.argocd.namespace $port -}}
{{- end -}}

{{- define "argocdServer.target" -}}
  {{- $port := .Values.metrics.services.argocd.serverMetricPort | toString -}}
  {{- printf "%s-server-metrics.%s.svc.cluster.local:%s" .Values.metrics.services.argocd.releaseName .Values.metrics.services.argocd.namespace $port -}}
{{- end -}}

{{- define "certManager.target" -}}
  {{- $port := .Values.metrics.services.certManager.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.certManager.releaseName .Values.metrics.services.certManager.namespace $port -}}
{{- end -}}

{{- define "velero.target" -}}
  {{- $port := .Values.metrics.services.velero.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.velero.releaseName .Values.metrics.services.velero.namespace $port -}}
{{- end -}}

{{- define "hashicorpVault.target" -}}
  {{- $port := .Values.metrics.services.hashicorpVault.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.hashicorpVault.releaseName .Values.metrics.services.hashicorpVault.namespace $port -}}
{{- end -}}

{{- define "hashicorpConsul.target" -}}
  {{- $port := .Values.metrics.integrations.hashicorpConsul.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.integrations.hashicorpConsul.releaseName .Values.metrics.integrations.hashicorpConsul.namespace $port -}}
{{- end -}}

{{- define "redis.target" -}}
  {{- $port := .metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .releaseName .namespace $port -}}
{{- end -}}

{{- define "ingressNginx.target" -}}
  {{- $port := .Values.metrics.services.ingressNginx.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.ingressNginx.releaseName .Values.metrics.services.ingressNginx.namespace $port -}}
{{- end -}}

{{- define "trivy.target" -}}
  {{- $port := .Values.metrics.services.trivy.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.trivy.releaseName .Values.metrics.services.trivy.namespace $port -}}
{{- end -}}

{{/*
*****************************************
Compute statefulset service account name
*****************************************
*/}}
{{- define "statefulset.ServiceAccountName" -}}
  {{- if ne .Values.statefulset.serviceAccountName "" -}}
    {{- printf "%s" .Values.statefulset.serviceAccountName -}}
  {{- else -}}
    {{- printf "%s-service-account" .Release.Name -}}
  {{- end -}}
{{- end -}}

{{/*
*****************************************
Compute daemonset service account name
*****************************************
*/}}
{{- define "daemonset.ServiceAccountName" -}}
  {{- if ne .Values.daemonset.serviceAccountName "" -}}
    {{- printf "%s" .Values.daemonset.serviceAccountName -}}
  {{- else -}}
    {{- printf "%s-service-account" .Release.Name -}}
  {{- end -}}
{{- end -}}

{{/*
*****************************************
URLs for Prometheus and Loki
*****************************************
*/}}
{{- define "urls.prometheusRemoteWriteUrl" -}}
  {{- printf "${PROMETHEUS_REMOTE_WRITE_URL}" -}}
{{- end -}}

{{- define "urls.lokiUrl" -}}
  {{- printf "${LOKI_WRITE_URL}" -}}
{{- end -}}

{{/*
*****************************************
Prometheus and Loki IDs and passwords
*****************************************
*/}}
{{- define "credentials.prometheusId" -}}
  {{- printf "${PROMETHEUS_USER}" -}}
{{- end -}}

{{- define "credentials.prometheusPassword" -}}
  {{- printf "${PROMETHEUS_PASSWORD}" -}}
{{- end -}}

{{- define "credentials.lokiId" -}}
  {{- printf "${LOKI_USER}" -}}
{{- end -}}

{{- define "credentials.lokiPassword" -}}
  {{- printf "${LOKI_PASSWORD}" -}}
{{- end -}}


{{/*
*****************************************
Vault paths for Prometheus and Loki secrets
*****************************************
*/}}
{{- define "vaultSecrets.prometheusUserPath" -}}
  {{- if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.environment  .Values.global.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusUserKey" -}}
  {{- printf "prometheus_user" -}}
{{- end -}}

{{- define "vaultSecrets.prometheusPasswordPath" -}}
  {{- if or (eq .Values.global.environment "cloudopsdev") -}}
    {{- printf "grafana_oss_passwords/dev" -}}
  {{- else if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") (eq .Values.global.environment "stage") -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else -}}
    {{- printf "portal_api_keys" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusPasswordKey" -}}
  {{- if or (eq .Values.global.environment "cloudopsdev") (eq .Values.global.environment "dev") (eq .Values.global.environment "test") (eq .Values.global.environment "stage") -}}
    {{- printf "prometheus_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiUserPath" -}}
  {{- if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.environment .Values.global.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiUserKey" -}}
  {{- printf "loki_user" -}}
{{- end -}}

{{- define "vaultSecrets.lokiPasswordPath" -}}
  {{- if or (eq .Values.global.environment "cloudopsdev") -}}
    {{- printf "grafana_oss_passwords/dev" -}}
  {{- else if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") (eq .Values.global.environment "stage") -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else -}}
    {{- printf "portal_api_keys" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiPasswordKey" -}}
  {{- if or (eq .Values.global.environment "cloudopsdev") (eq .Values.global.environment "dev") (eq .Values.global.environment "test") (eq .Values.global.environment "stage") -}}
    {{- printf "loki_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusRemoteWriteUrlPath" -}}
  {{- if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.environment .Values.global.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusRemoteWriteUrlKey" -}}
  {{- printf "prometheus_remote_write_url" -}}
{{- end -}}

{{- define "vaultSecrets.lokiWriteUrlPath" -}}
  {{- if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.environment .Values.global.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiWriteUrlKey" -}}
  {{- printf "loki_write_url" -}}
{{- end -}}
