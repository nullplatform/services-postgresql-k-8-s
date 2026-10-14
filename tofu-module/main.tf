###############################################################################
# Service Definition: Postgres DB (K8S)
###############################################################################
module "service_definition_postgres_db" {
  source            = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/service_definition?ref=v1.52.3"
  nrn               = var.nrn
  git_provider      = "github"
  repository_org    = "nullplatform"
  repository_name   = "services-postgresql-k-8-s"
  repository_branch = var.repository_branch
  service_path      = "postgres-db"
  service_name      = "Postgres DB"
  available_actions = ["run-ddl-query", "run-dml-query"]
  available_links   = ["database-user"]
}

###############################################################################
# Service Agent Association: Postgres DB (K8S)
#
# No api_key: nullplatform creates and manages the channel's credential, scoped
# to dispatching commands to agents. np_api_key only authenticates the provider
# and must be able to assign the controlplane:agent-dispatcher role.
###############################################################################
module "service_definition_channel_association_postgres_db" {
  source                       = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/service_definition_agent_association?ref=v8.7.0"
  nrn                          = var.nrn
  tags_selectors               = var.tags_selectors
  service_specification_slug   = module.service_definition_postgres_db.service_specification_slug
  repository_service_spec_repo = "nullplatform/services-postgresql-k-8-s"
  service_path                 = "postgres-db"

  depends_on = [module.service_definition_postgres_db]
}
