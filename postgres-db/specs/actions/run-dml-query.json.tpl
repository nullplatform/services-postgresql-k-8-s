{
  "name": "Run DML Query",
  "slug": "run-dml-query",
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
          "description": "DML statement to execute (SELECT, INSERT, UPDATE, DELETE)."
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
        "error":      {"type": "string"},
        "results":    {"type": "array", "items": {"type": "object"}},
        "textresult": {"type": "string"}
      }
    },
    "values": {}
  }
}
