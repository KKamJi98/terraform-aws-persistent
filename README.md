# terraform-aws-persistent

> 변동성이 적은 인프라.  
> NAT_INSTANCE를 사용하기 위해서는 NAT_INSTANCE가 DYNAMIC에 우선 생성되어 있어야 함

- iam user group
- iam role
- iam policy
- network
- security group
- rds
- s3

```
.
├── README.md
├── backend.tf
├── errored.tfstate
├── main.tf
├── modules
│   ├── ecr
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam_group_membership
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam_policy
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam_role
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── s3-bucket
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   └── security_group
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── template
│   ├── bastion-policy.json
│   ├── dev-policy.json
│   └── infra-policy.json
├── terraform.tfvars
├── variables.tf
└── versions.tf
```