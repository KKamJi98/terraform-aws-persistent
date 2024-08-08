# terraform-aws-persistent

> 변동성이 적은 인프라.  
> NAT_INSTANCE를 사용하기 위해서는 NAT_INSTANCE가 DYNAMIC에 우선 생성되어 있어야 함

- ecr
- iam user group
- iam policy
- iam role
- network
- rds
- s3
- security group

## 파일구조

```bash
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
│   ├── dev-policy.json
│   └── infra-policy.json
├── terraform.tfvars
├── variables.tf
└── versions.tf
```