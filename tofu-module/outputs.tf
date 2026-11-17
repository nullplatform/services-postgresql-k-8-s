################################################################################
# Outputs - Postgres DB Service Definition
################################################################################

output "service_specification_slug_postgres_db" {
  description = "Slug of the Postgres DB service specification"
  value       = module.service_definition_postgres_db.service_specification_slug
}

output "service_specification_id_postgres_db" {
  description = "ID of the Postgres DB service specification"
  value       = module.service_definition_postgres_db.service_specification_id
}
