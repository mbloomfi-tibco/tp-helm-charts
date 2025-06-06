{{/*
Copyright © 2025. Cloud Software Group, Inc.
This file is subject to the license terms contained
in the license file that is distributed with this file.
*/}}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "flogo-webserver.consts.appName" }}tp-cp-flogo-webserver{{ end -}}

{{/* A fixed short name for the configmap */}}
{{- define "flogo-webserver.consts.configMapName" }}flogo-webserver-configmap{{ end -}}

{{/* Component we're a part of. */}}
{{- define "flogo-webserver.consts.component" }}cp{{ end -}}
{{/*
    ===========================================================================
    SECTION: possible values for enumeration types in the global variables defined in values.yaml
    ===========================================================================
*/}}

{{- define "tp-control-plane-dnsdomain-configmap" }}tp-cp-core-dnsdomains{{ end -}}
{{- define "flogo-webserver.cp-env-configmap" }}cp-env{{ end -}}

{{/*
    ===========================================================================
    SECTION: labels
    ===========================================================================
*/}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "flogo-webserver.shared.labels.chartLabelValue" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels used by the resources in this chart
*/}}
{{- define "flogo-webserver.shared.labels.selector" -}}
app.kubernetes.io/name: {{ include "flogo-webserver.consts.appName" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.cloud.tibco.com/owner: {{ include "flogo-webserver.cp-instance-id" . }}
{{- end -}}

{{/*
Standard labels added to all resources created by this chart.
Includes labels used as selectors (i.e. template "labels.selector")
*/}}
{{- define "flogo-webserver.shared.labels.standard" -}}
{{ include  "flogo-webserver.shared.labels.selector" . }}
helm.sh/chart: {{ include "flogo-webserver.shared.labels.chartLabelValue" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end -}}

{{/*
    ===========================================================================
    SECTION: general purpose functions
    ===========================================================================
*/}}

{{- define "flogo-webserver.image.registry" }}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY" "default" "" "required" "false" "Release" .Release )}}
{{- end }}


{{/* set repository based on the registry url. We will have different repo for each one. */}}
{{- define "flogo-webserver.image.repository" -}}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_REPO" "default" "tibco-platform-docker-prod" "required" "false" "Release" .Release )}}
{{- end -}}

{{/* set repository based on the registry url. We will have different repo for each one. */}}
{{- define "flogo-webserver.integration.image.repository" -}}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_REPO" "default" "tibco-platform-docker-prod" "required" "false" "Release" .Release )}}
{{- end -}}



{{/* Control plane environment configuration. This will have shared configuration used across control plane components. */}}
{{- define "cp-env" -}}
{{- $data := (lookup "v1" "ConfigMap" .Release.Namespace "cp-env") }}
{{- $data | toYaml }}
{{- end }}

{{/* PVC configured for control plane. Fail if the pvc not exist */}}
{{- define "flogo-webserver.pvc-name" }}
{{- if .Values.pvcName }}
  {{- .Values.pvcName }}
{{- else }}
{{- include "cp-env.get" (dict "key" "CP_PVC_NAME" "default" "control-plane-pvc" "required" "true"  "Release" .Release )}}
{{- end }}
{{- end }}

{{/* Image pull secret configured for control plane. default value empty */}}
{{- define "flogo-webserver.container-registry.secret" }}
{{- if .Values.imagePullSecret }}
  {{- .Values.imagePullSecret }}
{{- else }}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_IMAGE_PULL_SECRET_NAME" "default" "" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{/* Control plane instance Id. default value local */}}
{{- define "flogo-webserver.cp-instance-id" }}
  {{- include "cp-env.get" (dict "key" "CP_INSTANCE_ID" "default" "cp1" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Service account configured for control plane. fail if service account not exist */}}
{{- define "flogo-webserver.service-account-name" }}
{{- if .Values.serviceAccount }}
  {{- .Values.serviceAccount }}
{{- else }}
  {{- include "cp-env.get" (dict "key" "CP_SERVICE_ACCOUNT_NAME" "default" "control-plane-sa" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{/* Control plane logging fluentbit. default value true */}}
{{- define "flogo-webserver.cp-logging-fluentbit-enabled" }}
  {{- include "cp-env.get" (dict "key" "CP_LOGGING_FLUENTBIT_ENABLED" "default" "true" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane OTEL service. default value otel-services */}}
{{- define "flogo-webserver.cp-otel-services" }}
  {{- include "cp-env.get" (dict "key" "CP_OTEL_SERVICE" "default" "otel-services" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane enable or disable resource constraints */}}
{{- define "flogo-webserver.enableResourceConstraints" -}}
{{- include "cp-env.get" (dict "key" "CP_ENABLE_RESOURCE_CONSTRAINTS" "default" "false" "required" "false"  "Release" .Release )}}
{{- end }}
