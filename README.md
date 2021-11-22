# muni-challenge

Made for the DevOps team in **Muni**, as a Terraform infraestructure AWS challenge!
This is an example of a implementation of a **AWS ECS** cluster usign a Application Load Balancer to manage traffic routing. This service contains containers that runs the official **Metabase** image on Docker Hub, providing data directly from a **AWS RDS - MySQL** data base. All over the same **AWS VPC**.

## Requirements
- An AWS active account (this example runs all over the free tier services, so any charges won´t be applied).
- Terraform installed (example developed over Terraform v1.0.1).
- AWS IAM user with enough permissions to create the described resources.
- User AWS Credentials configured on the AWS CLI. 