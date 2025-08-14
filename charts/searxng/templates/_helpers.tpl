{{/*
Expand the name of the chart.
*/}}
{{- define "searxng.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "searxng.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "searxng.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "searxng.labels" -}}
helm.sh/chart: {{ include "searxng.chart" . }}
{{ include "searxng.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "searxng.selectorLabels" -}}
app.kubernetes.io/name: {{ include "searxng.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "searxng.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "searxng.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the image tag to use
*/}}
{{- define "searxng.imageTag" -}}
{{- default .Chart.AppVersion .Values.image.tag }}
{{- end }}

{{/*
Create the Redis URL for SearXNG configuration
*/}}
{{- define "searxng.redisUrl" -}}
{{- if .Values.redis.enabled }}
{{- printf "redis://%s-redis-master:6379/0" (include "searxng.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create environment variables
*/}}
{{- define "searxng.envVars" -}}
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- if .Values.redis.enabled }}
- name: REDIS_URL
  value: {{ include "searxng.redisUrl" . | quote }}
{{- end }}
{{- end }}

{{/*
Create the ConfigMap name for SearXNG settings
*/}}
{{- define "searxng.configMapName" -}}
{{- printf "%s-config" (include "searxng.fullname" .) }}
{{- end }}

{{/*
Create volume mounts for SearXNG
*/}}
{{- define "searxng.volumeMounts" -}}
- name: searxng-config
  mountPath: /etc/searxng/settings.yml
  subPath: settings.yml
  readOnly: true
{{- if .Values.extraVolumeMounts }}
{{- toYaml .Values.extraVolumeMounts }}
{{- end }}
{{- end }}

{{/*
Create volumes for SearXNG
*/}}
{{- define "searxng.volumes" -}}
- name: searxng-config
  configMap:
    name: {{ include "searxng.configMapName" . }}
    items:
    - key: settings.yml
      path: settings.yml
{{- if .Values.extraVolumes }}
{{- toYaml .Values.extraVolumes }}
{{- end }}
{{- end }}