# Zestimate Update Function

> *DEPRECATED* This component has been merged into my primary mono-repo.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0, < 0.14.0 |
| aws | ~> 2.0 |
| aws | ~> 2.70 |
| random | ~> 2.2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 ~> 2.70 |
| terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_profile | Name of AWS profile to use for API access. | `string` | `"default"` | no |
| aws\_region | n/a | `string` | `"us-west-2"` | no |
| bucket\_key | Location of Zestimate history file in S3. | `string` | `"data/zestimate_history.csv"` | no |
| project | Default value for project tag. | `string` | `"zestimate"` | no |
| vpc\_cidr | CIDR for build VPC | `string` | `"192.168.0.0/16"` | no |
| zpid | Zillow property ID. | `any` | n/a | yes |
| zwsid | Zillow API ID. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| lambda\_role\_arn | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
