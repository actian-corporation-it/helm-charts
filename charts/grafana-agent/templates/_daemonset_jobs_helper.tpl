{{- define "daemonsetjobs.kubernetesPods" -}}
- job_name: kubernetes-pods
  kubernetes_sd_configs:
  - role: pod
  relabel_configs:
  - action: drop
    regex: "false"
    source_labels:
    - __meta_kubernetes_pod_annotation_prometheus_io_scrape
  - action: keep
    regex: .*-metrics
    source_labels:
    - __meta_kubernetes_pod_container_port_name
  - action: replace
    regex: (https?)
    replacement: $1
    source_labels:
    - __meta_kubernetes_pod_annotation_prometheus_io_scheme
    target_label: __scheme__
  - action: replace
    regex: (.+)
    replacement: $1
    source_labels:
    - __meta_kubernetes_pod_annotation_prometheus_io_path
    target_label: __metrics_path__
  - action: replace
    regex: (.+?)(\:\d+)?;(\d+)
    replacement: $1:$2
    source_labels:
    - __address__
    - __meta_kubernetes_pod_annotation_prometheus_io_port
    target_label: __address__
  - action: drop
    regex: ""
    source_labels:
    - __meta_kubernetes_pod_label_name
  - action: replace
    replacement: $1
    separator: /
    source_labels:
    - __meta_kubernetes_namespace
    - __meta_kubernetes_pod_label_name
    target_label: job
  - action: replace
    source_labels:
    - __meta_kubernetes_namespace
    target_label: namespace
  - action: replace
    source_labels:
    - __meta_kubernetes_pod_name
    target_label: pod
  - action: replace
    source_labels:
    - __meta_kubernetes_pod_container_name
    target_label: container
  - action: replace
    separator: ':'
    source_labels:
    - __meta_kubernetes_pod_name
    - __meta_kubernetes_pod_container_name
    - __meta_kubernetes_pod_container_port_name
    target_label: instance
  - action: labelmap
    regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
  - action: drop
    regex: Succeeded|Failed
    source_labels:
    - __meta_kubernetes_pod_phase
{{- end -}}

{{- define "daemonsetjobs.kubernetes" -}}
- job_name: kubernetes
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  kubernetes_sd_configs:
  - role: endpoints
  metric_relabel_configs:
  - action: keep
    regex: up|workqueue_queue_duration_seconds_bucket|process_cpu_seconds_total|process_resident_memory_bytes|workqueue_depth|rest_client_request_duration_seconds_bucket|workqueue_adds_total|rest_client_requests_total|apiserver_request_total
    source_labels:
    - __name__
  relabel_configs:
  - action: keep
    regex: apiserver
    source_labels:
    - __meta_kubernetes_service_label_component
  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: false
    server_name: kubernetes
{{- end -}}

{{- define "daemonsetjobs.kubernetesPodsLogsName" -}}
- job_name: kubernetes-pods-logs-name
  kubernetes_sd_configs:
  - role: pod
  pipeline_stages:
  - {{ .Values.logs.defaultPipelineStage }}: {}
  relabel_configs:
  - source_labels:
      - __meta_kubernetes_pod_label_name
    target_label: __service__
  - source_labels:
      - __meta_kubernetes_pod_node_name
    target_label: __host__
  - action: drop
    regex: ""
    source_labels:
      - __service__
  - action: replace
    replacement: $1
    separator: /
    source_labels:
      - __meta_kubernetes_namespace
      - __service__
    target_label: job
  - action: replace
    source_labels:
      - __meta_kubernetes_namespace
    target_label: namespace
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_name
    target_label: pod
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_container_name
    target_label: container
  - replacement: /var/log/pods/*$1/*.log
    separator: /
    source_labels:
      - __meta_kubernetes_pod_uid
      - __meta_kubernetes_pod_container_name
    target_label: __path__
{{- end -}}

{{- define "daemonsetjobs.kubernetesPodsLogsApp" -}}
- job_name: kubernetes-pods-logs-app
  kubernetes_sd_configs:
  - role: pod
  pipeline_stages:
  - {{ .Values.logs.defaultPipelineStage }}: {}
  relabel_configs:
  - action: drop
    regex: .+
    source_labels:
      - __meta_kubernetes_pod_label_name
  - source_labels:
      - __meta_kubernetes_pod_label_app
    target_label: __service__
  - source_labels:
      - __meta_kubernetes_pod_node_name
    target_label: __host__
  - action: drop
    regex: ""
    source_labels:
      - __service__
  - action: replace
    replacement: $1
    separator: /
    source_labels:
      - __meta_kubernetes_namespace
      - __service__
    target_label: job
  - action: replace
    source_labels:
      - __meta_kubernetes_namespace
    target_label: namespace
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_name
    target_label: pod
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_container_name
    target_label: container
  - replacement: /var/log/pods/*$1/*.log
    separator: /
    source_labels:
      - __meta_kubernetes_pod_uid
      - __meta_kubernetes_pod_container_name
    target_label: __path__
{{- end -}}

{{- define "daemonsetjobs.kubernetesPodsLogsDirectController" -}}
- job_name: kubernetes-pods-logs-direct-controllers
  kubernetes_sd_configs:
  - role: pod
  pipeline_stages:
  - {{ .Values.logs.defaultPipelineStage }}: {}
  relabel_configs:
  - action: drop
    regex: .+
    separator: ""
    source_labels:
      - __meta_kubernetes_pod_label_name
      - __meta_kubernetes_pod_label_app
  - action: drop
    regex: '[0-9a-z-.]+-[0-9a-f]{8,10}'
    source_labels:
      - __meta_kubernetes_pod_controller_name
  - source_labels:
      - __meta_kubernetes_pod_controller_name
    target_label: __service__
  - source_labels:
      - __meta_kubernetes_pod_node_name
    target_label: __host__
  - action: drop
    regex: ""
    source_labels:
      - __service__
  - action: replace
    replacement: $1
    separator: /
    source_labels:
      - __meta_kubernetes_namespace
      - __service__
    target_label: job
  - action: replace
    source_labels:
      - __meta_kubernetes_namespace
    target_label: namespace
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_name
    target_label: pod
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_container_name
    target_label: container
  - replacement: /var/log/pods/*$1/*.log
    separator: /
    source_labels:
      - __meta_kubernetes_pod_uid
      - __meta_kubernetes_pod_container_name
    target_label: __path__
{{- end -}}

{{- define "daemonsetjobs.kubernetesPodsLogsIndirectControllers" -}}
- job_name: kubernetes-pods-logs-indirect-controller
  kubernetes_sd_configs:
  - role: pod
  pipeline_stages:
  - {{ .Values.logs.defaultPipelineStage }}: {}
  relabel_configs:
  - action: drop
    regex: .+
    separator: ""
    source_labels:
      - __meta_kubernetes_pod_label_name
      - __meta_kubernetes_pod_label_app
  - action: keep
    regex: '[0-9a-z-.]+-[0-9a-f]{8,10}'
    source_labels:
      - __meta_kubernetes_pod_controller_name
  - action: replace
    regex: ([0-9a-z-.]+)-[0-9a-f]{8,10}
    source_labels:
      - __meta_kubernetes_pod_controller_name
    target_label: __service__
  - source_labels:
      - __meta_kubernetes_pod_node_name
    target_label: __host__
  - action: drop
    regex: ""
    source_labels:
      - __service__
  - action: replace
    replacement: $1
    separator: /
    source_labels:
      - __meta_kubernetes_namespace
      - __service__
    target_label: job
  - action: replace
    source_labels:
      - __meta_kubernetes_namespace
    target_label: namespace
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_name
    target_label: pod
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_container_name
    target_label: container
  - replacement: /var/log/pods/*$1/*.log
    separator: /
    source_labels:
      - __meta_kubernetes_pod_uid
      - __meta_kubernetes_pod_container_name
    target_label: __path__
{{- end -}}

{{- define "daemonsetjobs.kubernetesPodsLogsStatic" -}}
- job_name: kubernetes-pods-logs-static
  kubernetes_sd_configs:
  - role: pod
  pipeline_stages:
  - {{ .Values.logs.defaultPipelineStage }}: {}
  relabel_configs:
  - action: drop
    regex: ""
    source_labels:
      - __meta_kubernetes_pod_annotation_kubernetes_io_config_mirror
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_label_component
    target_label: __service__
  - source_labels:
      - __meta_kubernetes_pod_node_name
    target_label: __host__
  - action: drop
    regex: ""
    source_labels:
      - __service__
  - action: replace
    replacement: $1
    separator: /
    source_labels:
      - __meta_kubernetes_namespace
      - __service__
    target_label: job
  - action: replace
    source_labels:
      - __meta_kubernetes_namespace
    target_label: namespace
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_name
    target_label: pod
  - action: replace
    source_labels:
      - __meta_kubernetes_pod_container_name
    target_label: container
  - replacement: /var/log/pods/*$1/*.log
    separator: /
    source_labels:
      - __meta_kubernetes_pod_annotation_kubernetes_io_config_mirror
      - __meta_kubernetes_pod_container_name
    target_label: __path__
{{- end -}}
