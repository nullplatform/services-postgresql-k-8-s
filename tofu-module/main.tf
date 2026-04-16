###############################################################################
# Service Definition: Postgres DB (K8S)
###############################################################################
module "service_definition_postgres_db" {
  source            = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/service_definition?ref=v1.52.3"
  nrn               = var.nrn
  git_provider      = "local"
  local_specs_path  = "/.np/services/databases/postgres/k8s"
  service_path      = "databases/postgres/k8s"
  service_name      = "Postgres DB"
  available_actions = ["run-ddl-query", "run-dml-query"]
  available_links   = ["database-user"]
}
###############################################################################
# Service Agent Association: Postgres DB (K8S)
###############################################################################
module "service_definition_channel_association_postgres_db" {
  source                     = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/service_definition_agent_association?ref=v1.43.0"
  nrn                        = var.nrn
  api_key                    = var.np_api_key
  tags_selectors             = var.tags_selectors
  service_specification_slug = module.service_definition_postgres_db.service_specification_slug
  agent_command = {
    type = "exec"
    data = {
      cmdline     = "nullplatform/services/databases/postgres/k8s/entrypoint/entrypoint"
      environment = { NP_ACTION_CONTEXT = "$${NOTIFICATION_CONTEXT}" }
    }
  }
  depends_on = [ module.service_definition_postgres_db ]
}
