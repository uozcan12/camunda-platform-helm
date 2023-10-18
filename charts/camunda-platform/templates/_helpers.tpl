{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "camundaPlatform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (for example,
by the DNS naming spec). If release name contains chart name it will be used as a full name.
*/}}
{{- define "camundaPlatform.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
[camunda-platform] Create a default fully qualified app name for component.

Example:
{{ include "camundaPlatform.componentFullname" (dict "componentName" "foo" "componentValues" .Values.foo "context" $) }}
*/}}
{{- define "camundaPlatform.componentFullname" -}}
    {{- if (.componentValues).fullnameOverride -}}
        {{- .componentValues.fullnameOverride | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- $name := default .componentName (.componentValues).nameOverride -}}
        {{- if contains $name .context.Release.Name -}}
            {{- .context.Release.Name | trunc 63 | trimSuffix "-" -}}
        {{- else -}}
            {{- printf "%s-%s" .context.Release.Name $name | trunc 63 | trimSuffix "-" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Define common labels, combining the match labels and transient labels, which might change on updating
(version depending). These labels should not be used on matchLabels selector, since the selectors are immutable.
*/}}
{{- define "camundaPlatform.labels" -}}
{{- template "camundaPlatform.matchLabels" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- if .Values.image }}
    {{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
    {{- else }}
app.kubernetes.io/version: {{ .Values.global.image.tag | quote }}
    {{- end }}
{{- else }}
app.kubernetes.io/version: {{ .Values.global.image.tag | quote }}
{{- end }}
{{- end }}

{{/*
Common match labels, which are extended by sub-charts and should be used in matchLabels selectors.
*/}}
{{- define "camundaPlatform.matchLabels" -}}
{{- if .Values.global.labels -}}
{{ toYaml .Values.global.labels }}
{{- end }}
app.kubernetes.io/name: {{ template "camundaPlatform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: camunda-platform
{{- end -}}

{{/*
Set image according the values of "base" or "overlay" values.
If the "overlay" values exist, they will override the "base" values, otherwise the "base" values will be used.
Usage: {{ include "camundaPlatform.imageByParams" (dict "base" .Values.global "overlay" .Values.retentionPolicy) }}
*/}}
{{- define "camundaPlatform.imageByParams" -}}
    {{- $imageRegistry := .overlay.image.registry | default .base.image.registry -}}
    {{- printf "%s%s%s:%s"
        $imageRegistry
        (empty $imageRegistry | ternary "" "/")
        (.overlay.image.repository | default .base.image.repository)
        (.overlay.image.tag | default .base.image.tag)
    -}}
{{- end -}}

{{/*
Set image according the values of "global" or "subchart" values.
Usage: {{ include "camundaPlatform.image" . }}
*/}}
{{- define "camundaPlatform.image" -}}
    {{ include "camundaPlatform.imageByParams" (dict "base" .Values.global "overlay" .Values) }}
{{- end -}}

{{/*
Set imagePullSecrets according the values of global, subchart, or empty.
*/}}
{{- define "camundaPlatform.subChartImagePullSecrets" -}}
    {{- if (.Values.image.pullSecrets) -}}
        {{- .Values.image.pullSecrets | toYaml -}}
    {{- else if (.Values.global.image.pullSecrets) -}}
        {{- .Values.global.image.pullSecrets | toYaml -}}
    {{- else -}}
        {{- "[]" -}}
    {{- end -}}
{{- end -}}

{{/*
Set imagePullSecrets for top-level components.
Usage:
{{ include "camundaPlatform.imagePullSecrets" (dict "component" "zeebe" "context" $) }}
*/}}
{{- define "camundaPlatform.imagePullSecrets" -}}
    {{- $componentValue := (index $.context.Values .component "image" "pullSecrets") -}}
    {{- $globalValue := (index $.context.Values.global "image" "pullSecrets") -}}
    {{- $componentValue | default $globalValue | default list | toYaml -}}
{{- end -}}

{{/*
[camunda-platform] Keycloak default URL.
*/}}

{{- define "camundaPlatform.keycloakDefaultHost" -}}
    {{- $keycloakDefaultHost := include "common.names.dependency.fullname" (dict "chartName" "keycloak" "chartValues" . "context" $) -}}
    {{- $keycloakDefaultHost -}}
{{- end -}}

{{/*
[camunda-platform] Keycloak URL which could be external.
*/}}

{{- define "camundaPlatform.keycloakURLBase" -}}
    http://{{- include "camundaPlatform.keycloakDefaultHost" . -}}:80
{{- end -}}

{{- define "camundaPlatform.keycloakURL" -}}
    {{- if .Values.global.identity.keycloak.url -}}
        {{- include "identity.keycloak.url" . -}}
    {{- else -}}
        {{- include "camundaPlatform.keycloakURLBase" . -}}{{- include "identity.keycloak.contextPath" . -}}
    {{- end -}}
{{- end -}}

{{/*
[camunda-platform] Keycloak issuer backend URL which used internally for Camunda apps.
*/}}

{{- define "camundaPlatform.issuerBackendUrl" -}}
    {{- include "camundaPlatform.keycloakURL" . -}}{{- .Values.global.identity.keycloak.realm -}}
{{- end -}}

{{/*
[camunda-platform] Keycloak auth token URL which used internally for Camunda apps.
*/}}

{{- define "camundaPlatform.authTokenUrl" -}}
    {{- include "camundaPlatform.issuerBackendUrl" . -}}/protocol/openid-connect/token
{{- end -}}

{{/*
[camunda-platform] Elasticsearch URL which could be external.
*/}}

{{- define "camundaPlatform.elasticsearchHost" -}}
    {{- tpl .Values.global.elasticsearch.host $ -}}
{{- end -}}

{{- define "camundaPlatform.elasticsearchURL" -}}
    {{- if .Values.global.elasticsearch.url -}}
        {{- .Values.global.elasticsearch.url -}}
    {{- else -}}
        {{ .Values.global.elasticsearch.protocol }}://{{ include "camundaPlatform.elasticsearchHost" . }}:{{ .Values.global.elasticsearch.port }}
    {{- end -}}
{{- end -}}

{{/*
[camunda-platform] Operate internal URL.
*/}}
{{ define "camundaPlatform.operateURL" }}
  {{- if .Values.operate.enabled -}}
    {{- print "http://" -}}{{- include "operate.fullname" . -}}:{{- .Values.operate.service.port -}}
    {{- .Values.operate.contextPath -}}
  {{- end -}}
{{- end -}}

{{/*
[camunda-platform] Identity internal URL.
*/}}
{{ define "camundaPlatform.identityURL" }}
  {{- if .Values.identity.enabled -}}
    {{- printf "http://%s:%v%s"
        (include "identity.fullname" .Subcharts.identity)
        .Values.identity.service.port
        (.Values.identity.contextPath | default "")
    -}}
  {{- end -}}
{{- end -}}


{{ define "camundaPlatform.releaseInfo" -}}
- name: {{ .Release.Name }}
  namespace: {{ .Release.Namespace }}
  version: {{ .Chart.Version }}
  components:
  {{- $proto := ternary "https" "http" .Values.global.ingress.tls.enabled -}}
  {{- $baseURL := printf "%s://%s" $proto .Values.global.ingress.host -}}

  {{- if .Values.console.enabled }}
  - name: Console
    url: {{ $baseURL }}{{ .Values.console.contextPath }}
  {{- end }}

  {{- with dict "Release" .Release "Chart" (dict "Name" "identity") "Values" .Values.identity }}
  {{ if .Values.enabled -}}
  - name: Keycloak
    url: {{ $baseURL }}{{ .Values.global.identity.keycloak.contextPath }}
  - name: Identity
    url: {{ $baseURL }}{{ .Values.contextPath }}
    readiness: http://{{ include "identity.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.service.port }}{{ .Values.readinessProbe.probePath }}
  {{- end }}
  {{- end }}

  {{ if .Values.operate.enabled -}}
  - name: Operate
    url: {{ $baseURL }}{{ .Values.operate.contextPath }}
    readiness: http://{{ include "operate.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.operate.service.port }}{{ .Values.operate.contextPath }}{{ .Values.operate.readinessProbe.probePath }}
  {{- end }}

  {{ if .Values.optimize.enabled -}}
  - name: Optimize
    url: {{ $baseURL }}{{ .Values.optimize.contextPath }}
    readiness: http://{{ include "optimize.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.optimize.service.port }}{{ .Values.optimize.contextPath }}{{ .Values.optimize.readinessProbe.probePath }}
  {{- end }}

  {{ if .Values.tasklist.enabled -}}
  - name: Tasklist
    url: {{ $baseURL }}{{ .Values.tasklist.contextPath }}
    readiness: http://{{ include "tasklist.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.tasklist.service.port }}{{ .Values.tasklist.contextPath }}{{ .Values.tasklist.readinessProbe.probePath }}
  {{- end }}

  {{- if .Values.webModeler.enabled }}
  - name: WebModeler WebApp
    url: {{ $baseURL }}{{ .Values.webModeler.contextPath }}
    readiness: http://{{ include "webModeler.webapp.fullname" . }}.{{ .Release.Namespace }}:{{ .Values.webModeler.webapp.service.port }}{{ .Values.webModeler.webapp.readinessProbe.probePath }}
  {{- end }}

  {{ if .Values.zeebe.enabled -}}
  - name: Zeebe Gateway
    url: grpc://{{ tpl .Values.zeebeGateway.ingress.host $ }}
    readiness: http://{{ include "zeebe.names.gateway" . | trimAll "\"" }}.{{ .Release.Namespace }}:{{ .Values.zeebeGateway.service.httpPort }}{{ .Values.zeebeGateway.contextPath }}{{ .Values.zeebeGateway.readinessProbe.probePath }}
  {{- end }}
{{- end -}}