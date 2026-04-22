# Postgres DB Service (Kubernetes)

Nullplatform **dependency service** that provisions and manages PostgreSQL instances on Kubernetes via the Bitnami Helm chart. Each application link creates a dedicated database user with configurable `read` / `write` / `admin` permissions.

The service lives under [`postgres-db/`](./postgres-db) so the repo stays open for future PostgreSQL-related services.

## What It Does

- Provisions a PostgreSQL instance via the Bitnami Helm chart (persistence, resources, optional PII security context)
- Generates the admin password on first install and stores it in a per-instance Kubernetes secret
- Creates a dedicated PostgreSQL user per link with scoped `read` / `write` / `admin` permissions
- Exposes `HOSTNAME` / `PORT` / `DBNAME` from the service and `USERNAME` / `PASSWORD` (secret) per link
- Supports ad-hoc `run-ddl-query` and `run-dml-query` actions executed by a throw-away client pod

## Repository Layout

```
.
├── postgres-db/
│   ├── specs/
│   │   ├── service-spec.json.tpl         # Service schema (attributes user sees)
│   │   ├── links/database-user.json.tpl  # Link schema (permissions, credentials)
│   │   └── actions/
│   │       ├── run-ddl-query.json.tpl
│   │       └── run-dml-query.json.tpl
│   ├── workflows/k8s/                    # Workflow YAMLs (create/update/delete/link/link-update/unlink/run-ddl-query/run-dml-query)
│   ├── scripts/k8s/                      # build_context, build_user_context, do_helm, run_query, write_*_outputs, cleanup_pvc, ensure_tools, ...
│   ├── entrypoint/                       # entrypoint/service/link (agent entrypoint trio)
│   ├── values.yaml                       # Static config (namespace, chart repo, chart version)
│   └── values.yaml.tpl                   # Bitnami chart values template (gomplate)
├── tofu-module/                          # OpenTofu module to register the service in nullplatform
└── README.md
```

## Service Configuration Parameters

Exposed in the nullplatform UI when creating/updating the service:

| Parameter | Type | Default | Allowed Values | Editable After Create |
|---|---|---|---|---|
| `usage_type` | enum | — | `transactions`, `cache`, `configurations` | No |
| `pii` | bool | `false` | | Yes |

The database name is derived from `usage_type` as `<usage_type>_db`.

## Link Parameters (`database-user`)

| Parameter | Type | Default | Description |
|---|---|---|---|
| `permisions.read` | bool | `true` | `SELECT` on all tables in the `public` schema |
| `permisions.write` | bool | `false` | `INSERT / UPDATE / DELETE` on all tables in the `public` schema |
| `permisions.admin` | bool | `false` | DDL / schema management (`SUPERUSER`) |

## Service Attributes (post-create, exported as env vars)

| Attribute | Description |
|---|---|
| `hostname` | ClusterIP of the PostgreSQL service |
| `port` | `5432` |
| `dbname` | Database name |

## Link Attributes (per link, exported as env vars)

| Attribute | Env Var Type | Description |
|---|---|---|
| `username` | plain | Auto-generated PostgreSQL username |
| `password` | secret | Auto-generated password (delivered as secret env var) |

## Workflows

| Workflow | Trigger | What It Does |
|---|---|---|
| `create` | Service created | Renders values, installs/upgrades the Helm release, creates the admin secret on first install, waits for readiness, persists service attributes |
| `update` | Service updated | Re-renders values and runs `helm upgrade`, persists refreshed attributes |
| `delete` | Service deleted | `helm uninstall` + cleanup of PVC / bound PV / admin secret |
| `link` | Application linked | Creates a new user with a random password and applies the permissions |
| `link-update` | Link updated | Revokes everything and re-grants according to the new permissions (password unchanged) |
| `unlink` | Application unlinked | `REASSIGN OWNED` to postgres, `DROP OWNED`, `DROP USER` |
| `run-ddl-query` | Custom action | Validates that the query is DDL (`CREATE / ALTER / DROP / TRUNCATE`) and runs it via a throw-away client pod |
| `run-dml-query` | Custom action | Validates that the query is DML (`SELECT / INSERT / UPDATE / DELETE`), wraps SELECTs in `json_agg(row_to_json(...))` to return structured results |

## Requirements

### nullplatform prerequisites

- A nullplatform agent with kubectl/helm access to the target cluster

### Cluster prerequisites

The Kubernetes cluster where this service runs must have:

- A **default `StorageClass`** — the Bitnami chart requests a `PersistentVolumeClaim` without specifying `storageClassName`. Without a default, the postgres pod will stay `Pending` forever.
- A **running CSI driver** backing that StorageClass, with IAM permissions to create volumes in your cloud. Managed Kubernetes offerings don't all ship one by default — notably AWS EKS requires the `aws-ebs-csi-driver` addon.
- An **nullplatform agent** with RBAC to create `ConfigMap`, `Secret`, `Pod`, `PersistentVolumeClaim` resources in the `postgres-db` namespace and to install Helm releases there. The standard agent chart already grants these.

### Runtime dependencies (on the agent pod)

- `kubectl`
- `helm` (≥ 3.17)
- `gomplate` (used to render `values.yaml.tpl`)
- `jq`, `openssl`, `uuidgen`

Anything missing is installed on-demand by `scripts/k8s/ensure_tools`.

## How to register this service in nullplatform

Register the service definition in your nullplatform account using the provided OpenTofu module under [`tofu-module/`](./tofu-module):

```hcl
module "postgres_db" {
  source = "git::https://github.com/nullplatform/services-postgresql-k-8-s.git//tofu-module?ref=main"

  nrn            = var.nrn
  np_api_key     = var.np_api_key
  tags_selectors = var.tags_selectors
}
```

**Variables:**

| Variable | Type | Sensitive | Description |
|---|---|---|---|
| `nrn` | `string` | No | Nullplatform Resource Name |
| `np_api_key` | `string` | Yes | API key for authenticating with nullplatform |
| `tags_selectors` | `map(string)` | No | Tags used to select channels and agents |
| `repository_branch` | `string` | No | Branch to pull specs from (default `main`) |

**Outputs:**

| Output | Description |
|---|---|
| `service_specification_slug_postgres_db` | Slug of the Postgres DB service specification |
| `service_specification_id_postgres_db` | ID of the Postgres DB service specification |

The module internally uses [`nullplatform/tofu-modules`](https://github.com/nullplatform/tofu-modules):

- `nullplatform/service_definition@v1.52.3` — registers the service spec from this repo on GitHub
- `nullplatform/service_definition_agent_association@v1.43.0` — wires the agent command to the service (pointing at `postgres-db/entrypoint/entrypoint`)

Requires the `nullplatform` Terraform provider `~> 0.0.75`.

## Important considerations

### Data loss on delete

Deleting the service runs `helm uninstall` and then deletes the PVC (and bound PV, if present). **Any data written to the database is lost.** There is no backup hook in this service — take one out-of-band before deleting if it matters.

### Admin credentials are long-lived

The admin password is generated once, on first install, and persisted in the `<project>-postgres-credentials` Kubernetes secret. Subsequent `helm upgrade` runs reuse it. There is no rotation hook; rotate by deleting the secret and re-running `update`, accepting that any open connections will break.

### Service ClusterIP is an implementation detail

Apps consume the service via the `hostname` attribute, which is the ClusterIP at creation time. ClusterIPs are stable for the lifetime of the Service resource in Kubernetes, so this works — but if the Service is recreated (e.g. `helm uninstall` followed by `helm install`), the IP changes and linked apps need to be re-linked or the service updated.

### Release name is tied to the application

The Helm release name is `<service-slug>-<application-id>-postgres`. That means the same service spec can be instantiated across multiple applications and each gets its own release, but renaming an application after creation is not supported (the release name would drift from the service identifier).

## Troubleshooting

| Symptom | Likely cause | Resolution |
|---|---|---|
| `Failed to get PostgreSQL service IP` | Pod not scheduling | Check node resources and PVC availability; verify the default StorageClass + CSI driver are healthy |
| `Permission denied` on a query | Wrong user permissions | Update the `database-user` link permissions |
| `Only DDL queries are allowed` | Wrong action used | Use `run-dml-query` for `SELECT / INSERT / UPDATE / DELETE` |
| `helm release pending` | Previous install failed mid-flight | `helm rollback` or `helm uninstall` the release and retry |

```bash
# Check pod status
kubectl get pods -n postgres-db

# View logs
kubectl logs -n postgres-db -l app.kubernetes.io/name=postgresql

# Check Helm release
helm status <project>-postgres -n postgres-db
```
