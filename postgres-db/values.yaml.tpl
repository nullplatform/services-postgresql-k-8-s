# Bitnami PostgreSQL Helm chart values. Rendered by gomplate from do_helm
# with context:
#   .projectName  — helm release / resource name prefix
#   .usageType    — "transactions" | "cache" | "configurations"
#   .piiEnabled   — true when the service stores PII
#   .dbName       — database name to create on first install
nameOverride: "{{ .projectName }}-postgres"
fullnameOverride: "{{ .projectName }}-postgres"

auth:
  existingSecret: "{{ .projectName }}-postgres-credentials"
  secretKeys:
    adminPasswordKey: "postgres-password"
    userPasswordKey: "password"
  database: "{{ .dbName }}"
  username: "postgres"

primary:
  persistence:
    enabled: true
    size: 10Gi

  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi

{{- if .piiEnabled }}
  securityContext:
    enabled: true
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 1001
{{- end }}

service:
  type: ClusterIP
  ports:
    postgresql: 5432

commonLabels:
  usage-type: "{{ .usageType }}"
  pii-enabled: "{{ .piiEnabled }}"

metrics:
  enabled: false
