{{/* 

Copyright © 2023 - 2025. Cloud Software Group, Inc.
This file is subject to the license terms contained
in the license file that is distributed with this file.

*/}}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "o11y-service.consts.appName" }}o11y-service{{ end -}}

{{- define "o11y-service.fullname" }}o11y-service{{ end -}}

{{- define "o11y-service-dnsdomain-configmap" }}tp-cp-core-dnsdomains{{ end -}}

{{/*
    ===========================================================================
    SECTION: labels
    ===========================================================================
*/}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "o11y-service.shared.labels.chartLabelValue" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "o11y-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "o11y-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "o11y-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- tpl .Values.global.o11yservice.serviceAccount . }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "o11y-service.labels" -}}
helm.sh/chart: {{ include "o11y-service.chart" . }}
{{ include "o11y-service.shared.labels.selector" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels used by the resources in this chart
*/}}
{{- define "o11y-service.shared.labels.selector" -}}
app.kubernetes.io/name: {{ include "o11y-service.consts.appName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: "o11y"
{{- end -}}

{{/*
Standard labels added to all resources created by this chart.
Includes labels used as selectors (i.e. template "labels.selector")
*/}}
{{- define "o11y-service.shared.labels.standard" -}}
{{ include  "o11y-service.shared.labels.selector" . }}
app.cloud.tibco.com/created-by: {{ include "o11y-service.consts.appName" . }}
helm.sh/chart: {{ include "o11y-service.shared.labels.chartLabelValue" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end -}}

{{- define "o11y-service.image.registry" }}
    {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY" "default" "" "required" "false" "Release" .Release )}}
{{- end -}}

{{/* set repository based on the registry url. We will have different repo for each one. */}}
{{- define "o11y-service.image.repository" -}}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_REPO" "default" "tibco-platform-docker-prod" "required" "false" "Release" .Release )}}
{{- end -}}

{{/* Control plane environment configuration. This will have shared configuration used across control plane components. */}}
{{- define "cp-env" -}}
{{- $data := (lookup "v1" "ConfigMap" .Release.Namespace "cp-env") }}
{{- $data | toYaml }}
{{- end }}

{{/* Service account configured for control plane. fail if service account not exist */}}
{{- define "o11y-service.service-account-name" }}
{{- if .Values.serviceAccount }}
  {{- .Values.serviceAccount }}
{{- else }}
  {{- include "cp-env.get" (dict "key" "CP_SERVICE_ACCOUNT_NAME" "default" "control-plane-sa" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{/* Image pull secret configured for control plane. default value empty */}}
{{- define "o11y-service.container-registry.secret" }}
{{- if .Values.imagePullSecret }}
  {{- .Values.imagePullSecret }}
{{- else }}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_IMAGE_PULL_SECRET_NAME" "default" "" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{/* Control plane instance Id. default value local */}}
{{- define "o11y-service.cp-instance-id" }}
  {{- include "cp-env.get" (dict "key" "CP_INSTANCE_ID" "default" "cp1" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane dns domain. default value local */}}
{{- define "o11y-service.dns-domain" -}}
{{- include "cp-env.get" (dict "key" "CP_DNS_DOMAIN" "default" "local" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane OTEL service. default value otel-services */}}
{{- define "o11y-service.cp-otel-services" }}
  {{- include "cp-env.get" (dict "key" "CP_OTEL_SERVICE" "default" "otel-services" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane logging fluentbit. default value true */}}
{{- define "o11y-service.cp-logging-fluentbit-enabled" }}
  {{- include "cp-env.get" (dict "key" "CP_LOGGING_FLUENTBIT_ENABLED" "default" "true" "required" "false"  "Release" .Release )}}
{{- end }}

{{- define "o11y-service.cp-dp-url" -}}
  {{- if (include "o11y-service.isSingleNamespace" .) }}
    {{- "dp-%s."}}{{ .Release.Namespace }}{{".svc.cluster.local" -}}
  {{- else }}
    {{- "dp-%s."}}{{include "o11y-service.cp-instance-id" .}}{{"-tibco-sub-%s.svc.cluster.local" -}}
  {{- end -}}
{{ end -}}

{{- define "o11y-service.isSingleNamespace" }}
  {{- $isSubscriptionSingleNamespace := "" -}}
    {{- if eq "true" (include "cp-env.get" (dict "key" "CP_SUBSCRIPTION_SINGLE_NAMESPACE" "default" "true" "required" "false"  "Release" .Release )) -}}
        {{- $isSubscriptionSingleNamespace = "1" -}}
    {{- end -}}
  {{ $isSubscriptionSingleNamespace }}
{{- end }}

{{- define "o11y-service.CPCustomerEnv" }}
  {{- $isCPCustomerEnv := "false" -}}
    {{- if eq "true" (include "cp-env.get" (dict "key" "CP_SUBSCRIPTION_SINGLE_NAMESPACE" "default" "true" "required" "false"  "Release" .Release )) -}}
        {{- $isCPCustomerEnv = "true" -}}
    {{- end -}}
  {{ $isCPCustomerEnv }}
{{- end }}

{{/* PVC configured for control plane. Fail if the pvc not exist */}}
{{- define "o11y-service.pvc-name" }}
{{- if .Values.pvcName }}
  {{- .Values.pvcName }}
{{- else }}
{{- include "cp-env.get" (dict "key" "CP_PVC_NAME" "default" "control-plane-pvc" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{/* Control plane enable or disable resource constraints */}}
{{- define "o11y-service.enableResourceConstraints" -}}
{{- include "cp-env.get" (dict "key" "CP_ENABLE_RESOURCE_CONSTRAINTS" "default" "true" "required" "false"  "Release" .Release )}}
{{- end }}
