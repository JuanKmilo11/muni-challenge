# muni-challenge

Made for the DevOps team in **Muni**, as a Terraform infraestructure AWS challenge!
This is an example of a implementation of a **AWS ECS** cluster usign a Application Load Balancer to manage traffic routing. This service contains containers that runs the official **Metabase** image on Docker Hub, providing data directly from a **AWS RDS - MySQL** data base. All over the same **AWS VPC**.

## Requirements
- An AWS active account (this example runs all over the free tier services, so any charges won´t be applied).
- Terraform installed (example developed over Terraform v1.0.1).
- AWS IAM user with enough permissions to create the described resources.
- User AWS Credentials configured on the AWS CLI. 

## Infraestructure

The infraestructure developed its based on the following diagram:

 ![alt text](https://juanks3buckettest.s3.amazonaws.com/challenge_muni.PNG)

 According to this, and the description above, these are the general resources used on the implementation:

 - Network: VPC, Subnet and Internet Gateway.
 - Load Balancer: ALB, LB Target Group and LB Listener.  
 - Cloudwatch: Log Group and Stream.  
 - RDS: MySQL DB Instance.
 - ECS: Cluster, Task Definition and Service.
 - EC2: Launch configuration and Auto Scaling Group.
 - Others: Policies, Roles and Security Groups

 ## Implementation

Initialize the project and terraform files
 > terraform init
Review resources to be created
 > terraform plan
Upload changes and initialized 
 > terraform apply

Reverse changes (if wanted)
 >terraform destroy
 



 