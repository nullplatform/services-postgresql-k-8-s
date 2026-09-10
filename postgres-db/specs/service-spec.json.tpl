{
  "name": "Postgres DB",
  "slug": "postgres-db",
  "type": "dependency",
  "unique": false,
  "assignable_to": "any",
  "use_default_actions": true,
  "available_actions": ["run-ddl-query", "run-dml-query"],
  "available_links": ["database-user"],
  "selectors": {
    "category": "Database",
    "imported": false,
    "provider": "K8S",
    "sub_category": "Relational Database"
  },
  "attributes": {
    "schema": {
      "type": "object",
      "$schema": "http://json-schema.org/draft-07/schema#",
      "required": ["usage_type", "pii"],
      "properties": {
        "usage_type": {
          "type": "string",
          "title": "Usage Type",
          "enum": ["transactions", "cache", "configurations"],
          "description": "What this database is used for.",
          "editableOn": ["create"],
          "order": 1
        },
        "pii": {
          "type": "boolean",
          "title": "Stores PII",
          "default": false,
          "description": "Will you store personal user information (email, name, id, etc.)? Enables a non-root security context on the pod.",
          "editableOn": ["create", "update"],
          "order": 2
        },
        "hostname": {
          "type": "string",
          "title": "Hostname",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "ClusterIP assigned after creation (read-only).",
          "order": 3
        },
        "port": {
          "type": "number",
          "title": "Port",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "PostgreSQL port — always 5432 (read-only).",
          "order": 4
        },
        "dbname": {
          "type": "string",
          "title": "Database Name",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Database name derived from usage_type (read-only).",
          "order": 5
        },
        "k8s_secret_name": {
          "type": "string",
          "export": false,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Internal: name of the K8s secret holding admin credentials (needed by link workflows to fetch the admin password)."
        },
        "helm_release_name": {
          "type": "string",
          "export": false,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Internal: Helm release name for this service instance (needed by lifecycle scripts)."
        }
      }
    },
    "values": {}
  }
}
