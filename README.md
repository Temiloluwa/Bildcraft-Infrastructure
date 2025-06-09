# Bildcraft Shared Infrastructure

This repository contains modular Terraform code for managing shared AWS infrastructure resources for the Bildcraft project. It leverages [Cloud Posse](https://github.com/cloudposse) modules for best practices, maintainability, and extensibility.

## Features

- **Modular Design:** Uses Cloud Posse modules for S3 buckets and Lambda functions, wrapped in custom modules for project-specific logic.
- **Event-Driven Processing:** S3 buckets can trigger Lambda functions on object creation (e.g., for image translation workflows).
- **Centralized Lambda Source:** Lambda deployment packages are stored in a shared S3 bucket for easy updates and versioning.
- **Fine-Grained IAM:** IAM permissions are managed via module inputs, following least-privilege principles.
- **Environment Support:** Easily extensible for multiple environments via variable files.

## Directory Structure

```
├── README.md
└── iac/
    ├── image-translation.tf      # Image translation S3/Lambda wiring
    ├── locals.tf                 # Local values
    ├── main.tf                   # Root module configuration
    ├── outputs.tf                # Cross-module outputs
    ├── providers.tf              # AWS provider and backend
    ├── variables.tf              # Global variables
    ├── environment/
    │   └── prod-terraform.tfvars     # Production variables
    └── modules/
        ├── dynamodb_tables/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── lambda_fns/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── s3_buckets/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── sqs_queues/
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

## Usage

1. Install [Terraform](https://www.terraform.io/downloads.html).
2. Configure your AWS credentials and set required variables (see `variables.tf`).
3. Upload Lambda deployment packages to the shared S3 bucket (see output values for bucket name).
4. Run Terraform commands from the `iac/` directory:
   ```sh
   terraform init
   terraform plan -var-file=environment/prod-terraform.tfvars
   terraform apply -var-file=environment/prod-terraform.tfvars
   ```

## Notes
- State files and sensitive data are excluded via `.gitignore`.
- All infrastructure changes are managed via Terraform Cloud for safety and auditability.
- See module and file comments for further customization options.

