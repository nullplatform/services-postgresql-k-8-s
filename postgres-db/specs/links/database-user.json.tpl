{
  "name": "Database User",
  "slug": "database-user",
  "unique": false,
  "assignable_to": "any",
  "use_default_actions": true,
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
      "required": ["permisions"],
      "properties": {
        "permisions": {
          "type": "object",
          "title": "Permissions",
          "description": "Database permissions to grant this user.",
          "editableOn": ["create", "update"],
          "order": 1,
          "properties": {
            "read": {
              "type": "boolean",
              "title": "Read",
              "default": true,
              "description": "SELECT on all tables in the public schema."
            },
            "write": {
              "type": "boolean",
              "title": "Write",
              "default": false,
              "description": "INSERT / UPDATE / DELETE on all tables in the public schema."
            },
            "admin": {
              "type": "boolean",
              "title": "Admin",
              "default": false,
              "description": "DDL / schema management (SUPERUSER)."
            }
          }
        },
        "username": {
          "type": "string",
          "title": "Username",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Auto-generated database username (exported as env var).",
          "order": 2
        },
        "password": {
          "type": "string",
          "title": "Password",
          "export": {"type": "environment_variable", "secret": true},
          "secret": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Auto-generated database password (delivered as secret env var).",
          "order": 3
        }
      }
    },
    "values": {}
  }
}
