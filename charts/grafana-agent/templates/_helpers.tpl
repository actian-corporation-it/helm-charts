{{- define "prometheus.authentication" -}}
{{- $prometheusRemoteWriteUrl := (include "urls.prometheusRemoteWriteUrl" .) -}}
{{- $prometheusId := (include "credentials.prometheusId" .) -}}
{{- $prometheusPassword := (include "credentials.prometheusPassword" .) -}}
- url: {{ $prometheusRemoteWriteUrl }}
  {{- if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test") }}
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
- url: {{ $lokiUrl }}
  {{- if or (eq .Values.global.environment "dev") (eq .Values.global.environment "test")  }}
  tenant_id: engineering
  {{- else if eq .Values.global.environment "stage" }}
  tenant_id: stage
  {{- end }}
  basic_auth:
    username: {{ $lokiId }}
    password: {{ $lokiPassword }}
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

{{- define "agentConfig.externalLabels" -}}
  {{- range $key, $value := $.Values.global.externalLabels }}
    {{- if $value }}
    {{ $key }}: {{ $value }}
    {{- else }}{{ required (printf "\n\nMissing value: A value is required for metrics label %s\n" $key) nil }}
    {{- end }}
  {{- end }}
{{- end -}}

{{- define "rabbitmq.target" -}}
  {{- $port := .Values.metrics.services.rabbitmq.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.rabbitmq.releaseName .Values.metrics.services.rabbitmq.namespace $port -}}
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
  {{- $port := .Values.metrics.services.hashicorpConsul.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.hashicorpConsul.releaseName .Values.metrics.services.hashicorpConsul.namespace $port -}}
{{- end -}}

{{- define "ingressNginx.target" -}}
  {{- $port := .Values.metrics.services.ingressNginx.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.ingressNginx.releaseName .Values.metrics.services.ingressNginx.namespace $port -}}
{{- end -}}

{{- define "trivy.target" -}}
  {{- $port := .Values.metrics.services.trivy.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.services.trivy.releaseName .Values.metrics.services.trivy.namespace $port -}}
{{- end -}}

{{- define "grafanaAgent.Version" -}}
  {{- if eq .Values.global.agentVersion "" -}}
    {{- printf "%s" $.Chart.AppVersion -}}
  {{- else -}}
    {{- printf "%s" .Values.global.agentVersion -}}
  {{- end -}}
{{- end -}}

{{/*
Compute statefulset service account name
*/}}
{{- define "statefulset.ServiceAccountName" -}}
  {{- if ne .Values.statefulset.serviceAccountName "" -}}
    {{- printf "%s" .Values.statefulset.serviceAccountName -}}
  {{- else -}}
    {{- printf "%s-service-account" .Release.Name -}}
  {{- end -}}
{{- end -}}

{{/*
Compute daemonset service account name
*/}}
{{- define "daemonset.ServiceAccountName" -}}
  {{- if ne .Values.daemonset.serviceAccountName "" -}}
    {{- printf "%s" .Values.daemonset.serviceAccountName -}}
  {{- else -}}
    {{- printf "%s-service-account" .Release.Name -}}
  {{- end -}}
{{- end -}}

{{/*
URLs for Prometheus and Loki
*/}}
{{- define "urls.prometheusRemoteWriteUrl" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "%s" .Values.urls.us.prometheusRemoteWriteUrl -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.urls.us.prometheusRemoteWriteUrl -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.urls.us.prometheusRemoteWriteUrl -}}
  {{- else -}}
    {{- if eq .Values.global.grafanaRegion "eu" -}}
      {{- printf "%s" .Values.urls.eu.prometheusRemoteWriteUrl -}}
    {{- else -}}
      {{- printf "%s" .Values.urls.us.prometheusRemoteWriteUrl -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "urls.lokiUrl" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "%s" .Values.urls.us.lokiUrl -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.urls.us.lokiUrl -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.urls.us.lokiUrl -}}
  {{- else -}}
    {{- if eq .Values.global.grafanaRegion "eu" -}}
      {{- printf "%s" .Values.urls.eu.lokiUrl -}}
    {{- else -}}
      {{- printf "%s" .Values.urls.us.lokiUrl -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Prometheus and Loki IDs
*/}}
{{- define "credentials.prometheusId" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "%s" .Values.credentials.us.prometheusId -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.credentials.us.prometheusId -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.credentials.us.prometheusId -}}
  {{- else -}}
    {{- if eq .Values.global.grafanaRegion "eu" -}}
      {{- printf "%s" .Values.credentials.eu.prometheusId -}}
    {{- else -}}
      {{- printf "%s" .Values.credentials.us.prometheusId -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "credentials.prometheusPassword" -}}
  {{- printf "${MIMIR_PASSWORD}" -}}
{{- end -}}

{{- define "credentials.lokiId" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "%s" .Values.credentials.us.lokiId -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.credentials.us.lokiId -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.credentials.us.lokiId -}}
  {{- else -}}
    {{- if eq .Values.global.grafanaRegion "eu" -}}
      {{- printf "%s" .Values.credentials.eu.lokiId -}}
    {{- else -}}
      {{- printf "%s" .Values.credentials.us.lokiId -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "credentials.lokiPassword" -}}
  {{- printf "${LOKI_PASSWORD}" -}}
{{- end -}}


{{/*
Vault paths for Prometheus and Loki secrets
*/}}
{{- define "vaultSecrets.prometheusPasswordPath" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else -}}
    {{- printf "portal_api_keys" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusPasswordKey" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "mimir_password" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "mimir_password" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "mimir_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiPasswordPath" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else -}}
    {{- printf "portal_api_keys" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiPasswordKey" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "loki_password" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "loki_password" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "loki_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

