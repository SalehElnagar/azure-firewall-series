# Azure Firewall Foundation

This repository contains a standalone Terragrunt and Terraform implementation of a policy-based Azure Firewall hub-and-spoke foundation.

It is extracted from a larger platform monorepo and keeps only the reusable parts required for:

- Azure Firewall Standard with Azure Firewall Policy
- Hub and spoke virtual networks
- Hub to spoke peering
- Route table based egress steering
- Firewall diagnostics to Log Analytics
- Optional Linux test VM wiring, disabled by default

## Repository Layout

- `Modules/`: focused Terraform modules used by the foundation
- `Live/`: Terragrunt live configuration and YAML-driven environment data

## Deployment Model

Terragrunt is the entrypoint. The stack is defined under:

- `Live/network-security/foundation/`

Run units in this order:

1. `resource-group`
2. `log-analytics`
3. `hub-network`
4. `firewall-policy`
5. `firewall`
6. `spoke-network`
7. `peering`
8. `routing`
9. `diagnostics`
10. `test-vm` if enabled

## Before Use

- Update `Live/subscription.yaml` if you need to change subscription, backend, or git module ref values.
- Authenticate to Azure with Azure CLI or another supported AzureRM auth method.
- Ensure the backend storage account and container already exist.

## Notes

- The sample naming uses the shared conventions module and emits `CUS` when `centralus` is selected.
- Long configuration is stored in YAML so the Terragrunt HCL stays small and reviewable.
- The stack defaults to local `Modules/` sources so live Terragrunt changes validate against the code in this checkout. Set `TG_MODULE_SOURCE_PREFIX` to a git source when you want to consume a published module release instead.
- The `test-vm` unit defaults to a no-op path through the `noop` module.
- Shared naming and tagging come from the published `terraform-conventions` repository, pinned by the module internals to `v0.2.0`.
- The spoke VNet points at the firewall private IP for DNS when `network.spoke.use_firewall_dns_proxy` is enabled so article 2's DNS proxy control path is enforced, not just documented.
