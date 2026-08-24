{
    "name": "Rotate Password",
    "slug": "rotate-password",
    "type": "custom",
    "annotations": {},
    "retryable": true,
    "parameters": {
        "schema": {
            "type": "object",
            "required": [],
            "uiSchema": {
                "type": "VerticalLayout",
                "elements": []
            },
            "properties": {
                "new_password": {
                    "type": "string",
                    "format": "password",
                    "description": "Internal - set only by the rotation workflow. UI invocations auto-generate the password and store it in Vault; the pipeline applies it to the database. Never logged."
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
                "error": {
                    "type": "string"
                },
                "rotated": {
                    "type": "boolean"
                },
                "username": {
                    "type": "string",
                    "target": "username"
                },
                "password": {
                    "type": "string",
                    "secret": true,
                    "target": "password"
                }
            }
        },
        "values": {}
    }
}
