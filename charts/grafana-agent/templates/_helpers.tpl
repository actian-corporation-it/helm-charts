{{- define "metrics.authentication" -}}
- url: {{ .Values.metrics.prometheusRemoteWriteUrl }}
  basic_auth:
    username: {{ .Values.metrics.prometheusId }}
    password: {{ .Values.metrics.prometheusPassword }}
{{- end -}}

{{- define "logs.authentication" -}}
- url: {{ .Values.logs.lokiUrl }}
  basic_auth:
    username: {{ .Values.logs.lokiId }}
    password: {{ .Values.logs.lokiPassword }}
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

{{- define "rabbitmq.target" -}}
  {{- $port := .Values.metrics.ingtegrations.rabbitmq.metricPort | toString -}}
  {{- printf "%s.%s.svc.cluster.local:%s" .Values.metrics.integrations.rabbitmq.releaseName .Values.metrics.integrations.rabbitmq.namespace $port -}}
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
