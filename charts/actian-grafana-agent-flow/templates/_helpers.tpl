{{/*
*****************************************
Agent Log Level
*****************************************
*/}}
{{- define "actian.grafanaAgentLogLevel" -}}
{{- printf "%s" .Values.global.actian.agentLogLevel }}
{{- end -}}

{{/*
{{/*
*****************************************
Cluster Name
*****************************************
*/}}
{{- define "actian.clusterName" -}}
{{- printf "%s" .Values.global.actian.clusterName }}
{{- end -}}

{{/*
*****************************************
Cluster Environment
*****************************************
*/}}
{{- define "actian.clusterEnvironment" -}}
{{- printf "%s" .Values.global.actian.environment }}
{{- end -}}

{{/*
*****************************************
Cloud Service Provider
*****************************************
*/}}
{{- define "actian.cloudProvider" -}}
{{- printf "%s" .Values.global.actian.cloudProvider }}
{{- end -}}

{{/*
*****************************************
Cluster Region
*****************************************
*/}}
{{- define "actian.clusterRegion" -}}
{{- printf "%s" .Values.global.actian.clusterRegion }}
{{- end -}}

{{/*
*****************************************
Agent Modules Repository
*****************************************
*/}}
{{- define "actian.grafanaAgentModulesRepo" -}}
{{- if .Values.global.actian.modulesRepo -}}
{{- printf "%s" .Values.global.actian.modulesRepo }}
{{- else -}}
{{- print "https://bitbucket.org/actian/grafana-agent-modules.git" }}
{{- end -}}
{{- end -}}

{{/*
*****************************************
Agent Modules Revision
*****************************************
*/}}
{{- define "actian.grafanaAgentModulesRevision" -}}
{{- if .Values.global.actian.modulesRevision -}}
{{- printf "%s" .Values.global.actian.modulesRevision }}
{{- else -}}
{{- print "main" }}
{{- end -}}
{{- end -}}

{{/*
*****************************************
Grafana Stack
*****************************************
*/}}
{{- define "actian.grafanaStack" -}}
{{- if eq .Values.global.actian.environment "cloudopsdev" }}
  {{- printf "cloudopsdev" -}}
{{- else if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") }}
  {{- printf "engineering" -}}
{{- else if eq .Values.global.actian.environment "stage" }}
  {{- printf "stage" -}}
{{- else }}
  {{- printf "" -}}
{{- end }}
{{- end -}}

{{/*
*****************************************
Grafana Region
*****************************************
*/}}
{{- define "actian.grafanaRegion" -}}
{{- if or (eq .Values.global.actian.environment "cloudopsdev") (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") (eq .Values.global.actian.environment "stage") }}
  {{- printf "us" -}}
{{- else if eq .Values.global.actian.grafanaRegion "grafana_region" }}
  {{- printf "us" -}}
{{- else }}
  {{- printf "%s" .Values.global.actian.grafanaRegion -}}
{{- end }}
{{- end -}}

{{/*
*****************************************
Misc definitions
*****************************************
*/}}

{{- define "annotations.versions" -}}
{{- $grafanaAgentVersion := (include "grafanaAgent.Version" .) -}}
grafana_agent_versions: "Chart: {{ $.Chart.Name }} / {{ $.Chart.Version }}; grafana-agent: {{ $grafanaAgentVersion }}"
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
{{- $grafanaRegion := (include "actian.grafanaRegion" .) -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" $grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment  $grafanaRegion -}}
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
{{- $grafanaRegion := (include "actian.grafanaRegion" .) -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" $grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment $grafanaRegion -}}
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
{{- $grafanaRegion := (include "actian.grafanaRegion" .) -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" $grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment $grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.prometheusRemoteWriteUrlKey" -}}
  {{- printf "prometheus_remote_write_url" -}}
{{- end -}}

{{- define "vaultSecrets.lokiWriteUrlPath" -}}
{{- $grafanaRegion := (include "actian.grafanaRegion" .) -}}
  {{- if or (eq .Values.global.actian.environment "dev") (eq .Values.global.actian.environment "test") -}}
    {{- printf "paramstore/engineering/%s" $grafanaRegion -}}
  {{- else -}}
    {{- printf "paramstore/%s/%s" .Values.global.actian.environment $grafanaRegion -}}
  {{- end -}}
{{- end -}}

{{- define "vaultSecrets.lokiWriteUrlKey" -}}
  {{- printf "loki_write_url" -}}
{{- end -}}
