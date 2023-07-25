{{/*
*****************************************
Grafana Stack calculation
*****************************************
*/}}
{{- define "actian.grafanaStack" -}}
{{- if eq .Values.global.actian.environment "cloudopsdev" }}
  {{- printf "cloudopsdev" -}}
{{- else if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") }}
  {{- printf "engineering" -}}
{{- else if eq .Values.global.actian.environment "stage" }}
  {{- printf "stage" -}}
{{- end }}
{{- end -}}

{{/*
*****************************************
Misc definitions
*****************************************
*/}}

{{- define "annotations.versions" -}}
{{- $grafanaAgentVersion := (include "grafanaAgent.Version" .) -}}
grafana_agent_versions: "Chart: {{ $.Chart.Name }} / {{ $.Chart.Version }}; Agent_Chart: {{ $grafanaAgentVersion }}"
{{- end -}}

{{- define "grafanaAgent.Version" -}}
  {{- with (index $.Chart.Dependencies 1) }}
    {{- printf "%s" .Version -}}
  {{- end -}}
{{- end -}}

{{/*
*****************************************
Vault paths for Prometheus and Loki secrets
*****************************************
*/}}
{{- define "vaultSecrets.prometheusUserPath" -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.actian.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment  .Values.global.actian.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusUserKey" -}}
  {{- printf "prometheus_user" -}}
{{- end -}}

{{- define "vaultSecrets.prometheusPasswordPath" -}}
  {{- if or (eq .Values.global.actian.environment "cloudopsdev") -}}
    {{- printf "grafana_oss_passwords/dev" -}}
  {{- else if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") (eq .Values.global.actian.environment "stage") -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else -}}
    {{- printf "portal_api_keys" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusPasswordKey" -}}
  {{- if or (eq .Values.global.actian.environment "cloudopsdev") (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") (eq .Values.global.actian.environment "stage") -}}
    {{- printf "prometheus_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiUserPath" -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.actian.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment .Values.global.actian.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiUserKey" -}}
  {{- printf "loki_user" -}}
{{- end -}}

{{- define "vaultSecrets.lokiPasswordPath" -}}
  {{- if or (eq .Values.global.actian.environment "cloudopsdev") -}}
    {{- printf "grafana_oss_passwords/dev" -}}
  {{- else if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") (eq .Values.global.actian.environment "stage") -}}
    {{- printf "grafana_oss_passwords/production" -}}
  {{- else -}}
    {{- printf "portal_api_keys" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiPasswordKey" -}}
  {{- if or (eq .Values.global.actian.environment "cloudopsdev") (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") (eq .Values.global.actian.environment "stage") -}}
    {{- printf "loki_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusRemoteWriteUrlPath" -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.actian.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment .Values.global.actian.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusRemoteWriteUrlKey" -}}
  {{- printf "prometheus_remote_write_url" -}}
{{- end -}}

{{- define "vaultSecrets.lokiWriteUrlPath" -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" .Values.global.actian.grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment .Values.global.actian.grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiWriteUrlKey" -}}
  {{- printf "loki_write_url" -}}
{{- end -}}
