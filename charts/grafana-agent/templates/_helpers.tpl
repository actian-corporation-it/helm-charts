{{- define "prometheus.authentication" -}}
{{- $prometheusRemoteWriteUrl := (include "urls.prometheusRemoteWriteUrl" .) -}}
{{- $prometheusId := (include "credentials.prometheusId" .) -}}
{{- $prometheusPassword := (include "credentials.prometheusPassword" .) -}}
- url: {{ $prometheusRemoteWriteUrl }}
  basic_auth:
    username: {{ $prometheusId }}
    password: {{ $prometheusPassword }}
{{- end -}}

{{- define "loki.authentication" -}}
{{- $lokiUrl := (include "urls.lokiUrl" .) -}}
{{- $lokiId := (include "credentials.lokiId" .) -}}
{{- $lokiPassword := (include "credentials.lokiPassword" .) -}}
- url: {{ $lokiUrl }}
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
  {{- $port := .Values.metrics.integrations.rabbitmq.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.integrations.rabbitmq.releaseName .Values.metrics.integrations.rabbitmq.namespace $port -}}
{{- end -}}

{{- define "externalSecrets.target" -}}
  {{- $port := .Values.metrics.integrations.externalSecrets.metricPort | toString -}}
  {{- printf "%s-metrics.%s.svc.cluster.local:%s" .Values.metrics.integrations.externalSecrets.releaseName .Values.metrics.integrations.externalSecrets.namespace $port -}}
{{- end -}}

{{- define "argocd.target" -}}
  {{- $port := .Values.metrics.integrations.argocd.metricPort | toString -}}
  {{- printf "%s-metrics.%s.svc.cluster.local:%s" .Values.metrics.integrations.argocd.releaseName .Values.metrics.integrations.argocd.namespace $port -}}
{{- end -}}

{{- define "argocdServer.target" -}}
  {{- $port := .Values.metrics.integrations.argocd.serverMetricPort | toString -}}
  {{- printf "%s-server-metrics.%s.svc.cluster.local:%s" .Values.metrics.integrations.argocd.releaseName .Values.metrics.integrations.argocd.namespace $port -}}
{{- end -}}

{{- define "certManager.target" -}}
  {{- $port := .Values.metrics.integrations.certManager.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.integrations.certManager.releaseName .Values.metrics.integrations.certManager.namespace $port -}}
{{- end -}}

{{- define "velero.target" -}}
  {{- $port := .Values.metrics.integrations.velero.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.integrations.velero.releaseName .Values.metrics.integrations.velero.namespace $port -}}
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
    {{- printf "%s" .Values.urls.dev.us.prometheusRemoteWriteUrl -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.urls.test.us.prometheusRemoteWriteUrl -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.urls.stage.eu.prometheusRemoteWriteUrl -}}
  {{- else -}}
    {{- if eq .Values.global.region "eu" -}}
      {{- printf "%s" .Values.urls.production.eu.prometheusRemoteWriteUrl -}}
    {{- else -}}
      {{- printf "%s" .Values.urls.production.us.prometheusRemoteWriteUrl -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "urls.lokiUrl" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "%s" .Values.urls.dev.us.lokiUrl -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.urls.test.us.lokiUrl -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.urls.stage.eu.lokiUrl -}}
  {{- else -}}
    {{- if eq .Values.global.region "eu" -}}
      {{- printf "%s" .Values.urls.production.eu.lokiUrl -}}
    {{- else -}}
      {{- printf "%s" .Values.urls.production.us.lokiUrl -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Prometheus and Loki IDs
*/}}
{{- define "credentials.prometheusId" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "%s" .Values.credentials.dev.us.prometheusId -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.credentials.test.us.prometheusId -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.credentials.stage.eu.prometheusId -}}
  {{- else -}}
    {{- if eq .Values.global.region "eu" -}}
      {{- printf "%s" .Values.credentials.production.eu.prometheusId -}}
    {{- else -}}
      {{- printf "%s" .Values.credentials.production.us.prometheusId -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "credentials.prometheusPassword" -}}
  {{- printf "${PROMETHEUS_PASSWORD}" -}}
{{- end -}}

{{- define "credentials.lokiId" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "%s" .Values.credentials.dev.us.lokiId -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "%s" .Values.credentials.test.us.lokiId -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "%s" .Values.credentials.stage.eu.lokiId -}}
  {{- else -}}
    {{- if eq .Values.global.region "eu" -}}
      {{- printf "%s" .Values.credentials.production.eu.lokiId -}}
    {{- else -}}
      {{- printf "%s" .Values.credentials.production.us.lokiId -}}
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
    {{- printf "grafana_oss_passwords/engineering" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "grafana_oss_passwords/engineering" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "grafana_oss_passwords/stage" -}}
  {{- else -}}
    {{- printf "portal_api_keys" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusPasswordKey" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "prometheus_password" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "prometheus_password" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "prometheus_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiPasswordPath" -}}
  {{- if eq .Values.global.environment "dev" -}}
    {{- printf "grafana_oss_passwords/engineering" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "grafana_oss_passwords/engineering" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "grafana_oss_passwords/stage" -}}
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

