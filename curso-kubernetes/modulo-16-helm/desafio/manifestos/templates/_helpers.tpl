{{/*
  Helpers (funcoes reutilizaveis). Arquivos com _ no inicio NAO viram manifesto —
  servem so como "biblioteca" pra ser usada via {{ include "...".  }}.
*/}}

{{/* Nome curto da app = nome do chart */}}
{{- define "webapp.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/* Nome completo: release + chart, truncado em 63 chars (limite K8s pra DNS) */}}
{{- define "webapp.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Labels comuns aplicados em todos os recursos */}}
{{- define "webapp.labels" -}}
app.kubernetes.io/name: {{ include "webapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/* Labels de selector — subset estavel (nao muda em upgrade) */}}
{{- define "webapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
