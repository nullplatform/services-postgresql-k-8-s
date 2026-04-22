{
  "name": "Run DDL Query",
  "slug": "run-ddl-query",
  "type": "custom",
  "annotations": {},
  "retryable": false,
  "parameters": {
    "schema": {
      "type": "object",
      "$schema": "http://json-schema.org/draft-07/schema#",
      "required": ["query"],
      "uiSchema": {
        "type": "VerticalLayout",
        "elements": [
          {"type": "Control", "scope": "#/properties/query", "options": {"multi": true}}
        ]
      },
      "properties": {
        "query": {
          "type": "string",
          "title": "Query",
          "description": "DDL statement to execute (CREATE, ALTER, DROP, TRUNCATE)."
        }
      }
    },
    "values": {}
  },
  "results": {
    "schema": {
      "type": "object",
      "required": [],
      "properties": {
        "error":   {"type": "string"},
        "results": {"type": "string"}
      }
    },
    "values": {}
  }
}
