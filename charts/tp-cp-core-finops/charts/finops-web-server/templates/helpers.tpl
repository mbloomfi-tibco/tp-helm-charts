#
# Copyright © 2024. Cloud Software Group, Inc.
# This file is subject to the license terms contained
# in the license file that is distributed with this file.
#

{{/* Container registry for control plane. */}}
{{- define "finops-web-server.image.registry" }}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY" "default" "csgprdusw2reposaas.jfrog.io" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* secret for control plane. default value empty */}}
{{- define "cp-core-configuration.container-registry.secret" }}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_IMAGE_PULL_SECRET_NAME" "default" "" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* set repository based on the global value. */}}
{{- define "finops-web-server.image.repository" -}}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_REPO" "default" "tibco-platform-docker-prod" "required" "false"  "Release" .Release )}}
{{- end -}}

{{- define "tp-cp-core-finops.enableResourceConstraints" -}}
  {{- include "cp-env.get" (dict "key" "CP_ENABLE_RESOURCE_CONSTRAINTS" "default" "false" "required" "false"  "Release" .Release )}}
{{- end }}
