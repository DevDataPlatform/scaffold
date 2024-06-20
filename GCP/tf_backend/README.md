## Terraform Backend 
Sets up the Terraform backend for the project.

Instructions:
1. Install Terraform on your machine (https://www.terraform.io/downloads.html).
2. Initialize the backend by running the following command in the directory:
    `terraform init`
4. Configure the backend by creating a backend configuration file (tf_backend.auto.tfvars) with the necessary settings.
5. Run the following command to apply the backend configuration:
    `terraform apply`
6. Verify that the backend is successfully configured by running:
    `terraform show`