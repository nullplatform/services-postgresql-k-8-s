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
                "elements": [
                    {
                        "type": "Control",
                        "scope": "#/properties/new_password"
                    }
                ]
            },
            "properties": {
                "new_password": {
                    "type": "string",
                    "format": "password",
                    "description": "Optional. Leave empty to rotate via Vault: a new password is generated and written to Vault, which triggers the full rotation pipeline (webhook -> workflow -> ALTER USER + redeploy). When provided, the password is applied directly to the database user and the link's exported credential."
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
