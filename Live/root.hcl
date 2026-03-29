locals {
  live_root             = dirname(find_in_parent_folders("root.hcl"))
  common                = yamldecode(file(find_in_parent_folders("common.yaml")))
  subscription          = yamldecode(file(find_in_parent_folders("subscription.yaml")))
  module_source_prefix  = try(local.subscription.modules.source_prefix, "git::ssh://git@github.com/SalehElnagar/azure-firewall-series.git//Modules")
  module_ref            = get_env("TG_MODULE_REF", try(local.subscription.modules.ref, "article-01-foundation"))
  state_key_prefix      = trim(try(local.subscription.backend.state_key_prefix, ""), "/")

  env          = yamldecode(file(find_in_parent_folders("env.yaml")))
  region       = yamldecode(file(find_in_parent_folders("region.yaml")))
  tags_config  = yamldecode(file(find_in_parent_folders("tags.yaml")))
  network      = try(yamldecode(file(find_in_parent_folders("network.yaml"))), {})
  firewall     = try(yamldecode(file(find_in_parent_folders("firewall.yaml"))), {})
  diagnostics  = try(yamldecode(file(find_in_parent_folders("diagnostics.yaml"))), {})
  vm           = try(yamldecode(file(find_in_parent_folders("vm.yaml"))), {})

  foundation = local.env.foundation

  merged_tags = merge(
    try(local.tags_config.tags, {}),
    {
      SubscriptionKey = local.subscription.subscription_key
      ManagedBy       = "Terragrunt"
      DeploymentModel = "live"
    }
  )
}

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.auto.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    resource_group_name  = local.subscription.backend.resource_group_name
    storage_account_name = local.subscription.backend.storage_account_name
    container_name       = local.subscription.backend.container_name
    key                  = local.state_key_prefix != "" ? "${local.state_key_prefix}/${path_relative_to_include()}/${local.common.terragrunt.remote_state.state_file_name}" : "${path_relative_to_include()}/${local.common.terragrunt.remote_state.state_file_name}"
    subscription_id      = local.subscription.subscription_id
    use_azuread_auth     = try(local.common.terragrunt.remote_state.use_azuread_auth, true)
  }
}

generate "provider" {
  path      = "providers.auto.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  subscription_id = "${local.subscription.subscription_id}"
  tenant_id       = "${local.subscription.tenant_id}"
}
EOF
}
