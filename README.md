# services-postgresql-k8s

Nullplatform service definition for managed **PostgreSQL on Kubernetes**. Deploys and manages production-ready PostgreSQL instances via the Bitnami Helm chart, integrated with the nullplatform platform lifecycle (create, update, delete, actions, links).

## Overview

This repository packages the full lifecycle of a PostgreSQL database as a nullplatform **dependency service**. When registered, the platform can spin up isolated PostgreSQL instances per project, manage database users, and execute schema/data queries — all from the nullplatform dashboard or CLI.

| Property       | Value                  |
|----------------|------------------------|
| Service name   | `Postgres DB`          |
| Slug           | `postgres-db`          |
| Type           | Dependency             |
| Provider       | Kubernetes (K8S)       |
| Category       | Database / Relational  |
| Helm chart     | `bitnami/postgresql`   |

## Cluster Prerequisites

The Kubernetes cluster where this service runs must have:

- A **default `StorageClass`** — the chart requests a `PersistentVolumeClaim` without specifying `storageClassName`. Without a default, the postgres pod will stay `Pending` forever.
- A **running CSI driver** backing that StorageClass, with IAM permissions to create volumes in your cloud. Managed Kubernetes offerings don't all ship one by default (notably AWS EKS requires the `aws-ebs-csi-driver` addon).
- An **nullplatform agent** with RBAC to create `ConfigMap`, `Secret` and `Pod` resources in the `postgres-db` namespace, and to install Helm releases there (the standard agent chart already grants these).

## Architecture

```
nullplatform agent
       │
       ▼
handle-service-agent  ──►  np service-action exec
       │
       ├── service/
       │     ├── create-postgres-db    # helm upgrade --install
       │     ├── update-postgres-db    # re-render values + helm upgrade
       │     ├── delete-postgres-db    # helm uninstall + cleanup
       │     ├── run-ddl-query         # CREATE / ALTER / DROP / TRUNCATE
       │     └── run-dml-query         # SELECT / INSERT / UPDATE / DELETE
       │
       └── link/
             ├── create-database-user  # CREATE USER + set permissions
             ├── update-database-user  # GRANT / REVOKE permissions
             └── delete-database-user  # DROP USER
```

Each script reads its input from environment variables injected by the np agent (`ACTION_PARAMETERS_*`, `ACTION_SERVICE_ATTRIBUTES_*`, `NP_ACTION_CONTEXT`) and writes results back via `np service action update --results`.

## Features

- **Helm-managed lifecycle** — PostgreSQL installed/upgraded/removed via the Bitnami chart.
- **Templated values** — `values.yaml.tpl` rendered at runtime with `gomplate` using project-specific parameters.
- **PII security context** — when `pii: true`, the pod runs as non-root with `runAsUser: 1001`.
- **Credential management** — admin passwords auto-generated and stored in Kubernetes secrets; never hard-coded.
- **Database user links** — create per-application users with granular `read / write / admin` permissions.
- **DDL & DML actions** — execute schema migrations or data queries directly through the platform, with query-type validation.

## Service Attributes

| Attribute          | Type    | Required | Exported | Description                                      |
|--------------------|---------|----------|----------|--------------------------------------------------|
| `usage_type`       | enum    | Yes      | No       | `transactions`, `cache`, or `configurations`     |
| `pii`              | boolean | Yes      | No       | Enables security context for PII workloads       |
| `hostname`         | string  | No       | Yes      | ClusterIP assigned after creation (read-only)    |
| `port`             | number  | No       | Yes      | PostgreSQL port — always `5432` (read-only)      |
| `dbname`           | string  | No       | Yes      | Database name derived from `usage_type` (read-only)|

## Available Actions

### `run-ddl-query`

Executes DDL statements (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`) against the database using an in-cluster PostgreSQL client pod. Non-DDL queries are rejected with an error.

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    total NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `run-dml-query`

Executes DML statements (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) against the database.

```sql
INSERT INTO orders (user_id, total) VALUES (42, 99.99);
```

## Available Links

### `database-user`

Creates an isolated database user for an application to consume. Returns `username` and `password` as exported (secret) environment variables.

**Permission options** (`permisions` object):

| Field   | Type    | Default | Description              |
|---------|---------|---------|--------------------------|
| `read`  | boolean | `true`  | `SELECT` on all tables   |
| `write` | boolean | `false` | `INSERT / UPDATE / DELETE` |
| `admin` | boolean | `false` | DDL / schema management  |

## Installation

Register this service definition in your nullplatform account using the provided OpenTofu module under `tofu-module/`:

```hcl
module "postgres_db" {
  source = "path/to/services-postgresql-k8s/tofu-module"

  nrn            = var.nrn
  np_api_key     = var.np_api_key
  tags_selectors = var.tags_selectors
}
```

**Variables:**

| Variable        | Type          | Sensitive | Description                                      |
|-----------------|---------------|-----------|--------------------------------------------------|
| `nrn`           | `string`      | No        | Nullplatform Resource Name                       |
| `np_api_key`    | `string`      | Yes       | API key for authenticating with Nullplatform     |
| `tags_selectors`| `map(string)` | No        | Tags used to select channels and agents          |

**Outputs:**

| Output                                  | Description                                  |
|-----------------------------------------|----------------------------------------------|
| `service_specification_slug_postgres_db`| Slug of the Postgres DB service specification|
| `service_specification_id_postgres_db`  | ID of the Postgres DB service specification  |

The module internally uses:
- [`nullplatform/tofu-modules//nullplatform/service_definition@v1.52.3`](https://github.com/nullplatform/tofu-modules) — registers the service spec.
- [`nullplatform/tofu-modules//nullplatform/service_definition_agent_association@v1.43.0`](https://github.com/nullplatform/tofu-modules) — wires the agent command to the service.

Requires the `nullplatform` Terraform provider `~> 0.0.75`.

## Default Helm Values

```yaml
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

service:
  type: ClusterIP
  ports:
    postgresql: 5432

metrics:
  enabled: false
```

When `pii: true`, the following security context is applied to the primary pod:

```yaml
securityContext:
  enabled: true
  runAsNonRoot: true
  runAsUser: 1001
  fsGroup: 1001
```

## Directory Structure

```
.
├── postgres/k8s/
│   ├── handle-service-agent                # Entry point — delegates to np service-action exec
│   ├── entrypoint/entrypoint               # Alias entry point
│   ├── specs/                              # Nullplatform service contract templates
│   │   ├── service-spec.json.tpl
│   │   ├── actions/
│   │   │   ├── run-ddl-query.json.tpl
│   │   │   └── run-dml-query.json.tpl
│   │   └── links/
│   │       └── database-user.json.tpl
│   └── postgres-db/
│       ├── ensure_psql.sh                  # Installs psql client if missing
│       ├── run_query_in_pod.sh             # Runs SQL via a temporary K8s pod
│       ├── service/
│       │   ├── create-postgres-db
│       │   ├── update-postgres-db
│       │   ├── delete-postgres-db
│       │   ├── run-ddl-query
│       │   ├── run-dml-query
│       │   ├── handle-helm.sh              # Helm repo setup + chart install/upgrade
│       │   ├── project.sh                  # Resolves project name from context
│       │   ├── ensure_helm_deps.sh         # Ensures gomplate + helm are available
│       │   └── values.yaml.tpl             # Helm values template
│       └── link/
│           ├── create-database-user
│           ├── update-database-user
│           └── delete-database-user
└── tofu-module/                            # OpenTofu module to register the service in nullplatform
    ├── main.tf                             # service_definition + agent_association resources
    ├── variables.tf                        # nrn, np_api_key, tags_selectors
    ├── outputs.tf                          # service slug and ID outputs
    └── provider.tf                         # nullplatform provider ~> 0.0.75
```

## Troubleshooting

| Symptom | Likely cause | Resolution |
|---------|-------------|------------|
| `Failed to get PostgreSQL service IP` | Pod not scheduling | Check node resources and PVC availability |
| `Permission denied` on query | Wrong user permissions | Update the `database-user` link permissions |
| `Only DDL queries are allowed` error | Wrong action used | Use `run-dml-query` for SELECT/INSERT/UPDATE/DELETE |
| Helm release pending | Previous install failed | `helm rollback` or delete the release and retry |

```bash
# Check pod status
kubectl get pods -n postgres-db

# View logs
kubectl logs -n postgres-db -l app.kubernetes.io/name=postgresql

# Check Helm release
helm status <project>-postgres -n postgres-db
```