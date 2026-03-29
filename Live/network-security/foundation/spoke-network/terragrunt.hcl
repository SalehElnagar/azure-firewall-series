include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/virtual_network_v2?ref=${include.root.locals.module_ref}"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    name = "RG-CUS-PLATFORM-1-FIREWALL-FOUNDATION-DEV"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

locals {
  foundation = include.root.locals.foundation
  spoke      = include.root.locals.network.spoke
}

inputs = {
  location              = include.root.locals.region.location
  resource_group_name   = dependency.resource_group.outputs.name
  namespace             = local.foundation.namespace
  application           = local.foundation.application
  environment           = local.foundation.environment
  environment_instance  = local.foundation.environment_instance
  include_environment   = local.foundation.include_environment
  use_short_environment = local.foundation.use_short_environment
  purpose               = local.spoke.purpose
  attributes            = local.spoke.attributes
  address_space         = local.spoke.address_space
  dns_servers           = try(local.spoke.dns_servers, [])
  subnets               = local.spoke.subnets
  tags                  = include.root.locals.merged_tags
}
