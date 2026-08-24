{
    "name": "Rotate Password",
    "slug": "rotate-password",
    "type": "custom",
    "annotations": {},
    "retryable": true,
    "parameters": {
        "schema": {
            "type": "object",
            "required": [
                "new_password"
            ],
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
                    "description": "New password for the database user. The user's password is changed in the database (ALTER USER) and the link's exported credential is updated to match."
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
                    "type": "string"
                }
            }
        },
        "values": {}
    }
}
