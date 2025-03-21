# AWS EFS Module

This module creates AWS Elastic File System (EFS) with Security Group attached to it.

<!-- Next block is generated by terraform-docs following .terraform-docs.yml config -->
<!-- BEGIN_TF_DOCS -->
## Example

```hcl
# main.tf
module "efs_artefacts" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_efs"

  name           = "${local.codename}-artefacts"
  vpc_id         = local.subnet_group_vpc_id
  subnet_ids     = local.subnet_group_subnet_ids
  is_encrypted   = true
  enable_backup  = false
  # replica_region = local.account_config.aws_secondary_region_name
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | < 2.0.0, >= 1.6.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | < 6.0, >= 5.22 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | EFS Name | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the EFS will be created in | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs the EFS will be attached to | `list(string)` | n/a | yes |
| <a name="input_is_encrypted"></a> [is\_encrypted](#input\_is\_encrypted) | Enables disk encryption | `bool` | `true` | no |
| <a name="input_enable_backup"></a> [enable\_backup](#input\_enable\_backup) | Enables AWS EFS backup policy | `bool` | `false` | no |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | Enables a replication to an additional region | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | EFS ID |
| <a name="output_name"></a> [name](#output\_name) | EFS Name |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | EFS DNS Name |
| <a name="output_is_encrypted"></a> [is\_encrypted](#output\_is\_encrypted) | EFS Encryption Status |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | EFS Security Group ID |
| <a name="output_replica_region"></a> [replica\_region](#output\_replica\_region) | Region of the replicated EFS |
| <a name="output_replica_id"></a> [replica\_id](#output\_replica\_id) | ID of the replicated EFS |

## Resources

| Name | Type |
|------|------|
| [aws_efs_backup_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_replication_configuration.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_replication_configuration) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
<!-- END_TF_DOCS -->