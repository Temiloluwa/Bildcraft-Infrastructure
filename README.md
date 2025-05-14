# Infrastructure

This repository contains the Terraform code for managing shared infrastructure resources for the Bildcraft project.

## Structure

- `iac/` - Main Terraform configuration for shared infrastructure
  - `main.tf` - Root module configuration
  - `providers.tf` - Provider setup
  - `variables.tf` - Variable declarations
  - `outputs.tf` - Output definitions
  - `locals.tf` - Local values
  - `environment/` - Environment-specific variable files (e.g., `prod-terraform.tfvars`)
  - `modules/` - Reusable Terraform modules
    - `s3/` - S3 bucket module
    - `iam/` - IAM resources module

## Deployment

Deployment and state management are handled via [Terraform Cloud](https://app.terraform.io/). All plans and applies are executed remotely, and state is securely stored in Terraform Cloud workspaces.

## Usage

1. Install [Terraform](https://www.terraform.io/downloads.html) (for local development and validation).
2. Configure your AWS credentials and set the required variables (see `variables.tf`).
3. Changes pushed to the repository will trigger runs in Terraform Cloud.
4. For local validation, you can still run:
   ```sh
   terraform init
   terraform plan -var-file=environment/prod-terraform.tfvars
   ```

## Notes
- State files and sensitive data are excluded via `.gitignore`.
- Modules use the [Cloud Posse](https://github.com/cloudposse) Terraform modules for best practices.

