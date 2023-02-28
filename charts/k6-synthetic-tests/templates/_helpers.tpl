{{/*
Prometheus URL
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

{{/*
Prometheus ID
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

{{/*
Vault paths for Prometheus secrets
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
    {{- printf "prometheus_password" -}}
  {{- else if eq .Values.global.environment "test" -}}
    {{- printf "prometheus_password" -}}
  {{- else if or (eq .Values.global.environment "stage") (eq .Values.global.environment "staging") -}}
    {{- printf "prometheus_password" -}}
  {{- else -}}
    {{- printf "agent_authentication" -}}
  {{- end -}}
{{- end -}}

{{- define "synthetictests.execution" -}}
{{- $root := .root -}}
{{- $test := .test -}}
{{- $details := .details -}}
apiVersion: k6.io/v1alpha1
kind: K6
metadata:
  name: {{ $test }}
spec:
  parallelism: 1
  script:
    configMap:
      name: {{ $root.Values.syntheticTests.configMapName }}
      file: {{ $details.scriptName }}
  arguments: -o experimental-prometheus-rw --tag k6cluster={{ $root.Values.clusterName }}
  runner:
    image: {{ $root.Values.k6Image.name }}:{{ $root.Values.k6Image.tag }}
    imagePullSecrets:
      - name: {{ $root.Values.k6Image.secret }}
    env:
      - name: K6_KEEP_NAME_TAG
        value: 'true'
      - name: K6_KEEP_URL_TAG
        value: 'false'
      - name: K6_PROMETHEUS_RW_SERVER_URL
        valueFrom:
          secretKeyRef:
            name: {{ $root.Values.syntheticTests.secretName }}
            key: prometheusUrl
      - name: K6_PROMETHEUS_RW_USERNAME
        valueFrom:
          secretKeyRef:
            name: {{ $root.Values.syntheticTests.secretName }}
            key: prometheusUsername
      - name: K6_PROMETHEUS_RW_PASSWORD
        valueFrom:
          secretKeyRef:
            name: {{ $root.Values.syntheticTests.secretName }}
            key: prometheusPassword
      - name: username
        valueFrom:
          secretKeyRef:
            name: {{ $root.Values.syntheticTests.secretName }}
            key: {{ $details.usernameSecretKey }}
      - name: password
        valueFrom:
          secretKeyRef:
            name: {{ $root.Values.syntheticTests.secretName }}
            key: {{ $details.passwordSecretKey }}
{{- end -}}
