# Apache Guacamole Installation on AWS EC2 with HTTPS ALB using Terraform

This guide will walk you through the process of setting up Apache Guacamole on an AWS EC2 instance, along with an HTTPS Application Load Balancer (ALB), SSL certificate, CloudWatch integration, MariaDB database, and automatic start/stop using EventBridge and Lambda. This setup ensures a secure environment for accessing remote desktops and applications.

## Prerequisites

Before you begin, ensure you have the following prerequisites:

- An AWS account with appropriate permissions
- Terraform installed on your local machine
- AWS CLI installed and configured with your AWS credentials

## Architecture Overview

The following components will be provisioned in this setup:

- EC2 instance for Apache Guacamole
- Application Load Balancer (ALB) with HTTPS listener
- SSL/TLS certificate for secure communication
- MariaDB database for Guacamole configuration storage
- CloudWatch integration for logging and monitoring
- EventBridge rules and Lambda functions for automatic start/stop of the EC2 instance

## Getting Started

To get started with Apache Guacamole on AWS EC2 using Terraform, follow these steps:

### Step 1: Clone the Repository

Clone this repository to your local machine:

git clone <repository-url>
cd <repository-directory>

### Step 2: Update Variables

Open the `terraform.tfvars` file and update the variables as per your requirements. Provide the desired values for variables such as `aws_region`, `aws_access_key`, `aws_secret_key`, `ec2_key_name`, etc. Adjust any other variables if needed.

### Step 3: Initialize Terraform

Initialize Terraform in the repository directory by running the following command:

terraform init

### Step 4: Plan and Apply

Review the planned infrastructure changes before applying them. Run the following command:

terraform plan

If the plan looks good, apply the changes:

terraform apply

Terraform will create the necessary AWS resources, including the EC2 instance, security groups, ALB, SSL certificate, MariaDB database, CloudWatch integration, EventBridge rules, and Lambda functions.

### Step 5: Access Apache Guacamole

Once the Terraform apply is successful, you can access Apache Guacamole by opening the ALB DNS name provided in the Terraform output. The URL should be in the format `https://<alb-dns-name>`. Allow a few minutes for the ALB to be fully provisioned before accessing Apache Guacamole.

### Step 6: Configuration

Follow the Apache Guacamole documentation to configure the necessary connections and settings for your remote desktops and applications.

### Step 7: Automatic Start/Stop

The setup includes EventBridge rules and Lambda functions to automatically start and stop the EC2 instance hosting Apache Guacamole based on a predefined schedule. The Lambda functions will be triggered at the specified time intervals and perform the necessary actions. You can modify the schedule by updating the corresponding EventBridge rule and Lambda function code.

### DB Setup
mysql -u root -p
mysql -h mariadb.awscname.ap-southeast-1.rds.amazonaws.com -P 3306 -u root -p

CREATE DATABASE guacamole_db;
CREATE USER 'guacamole_user' IDENTIFIED BY 'ChangeIt';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user';
FLUSH PRIVILEGES;

cd /home/ubuntu/guacamole-server-1.5.2/guacamole-auth-jdbc-1.5.2/mysql/schema
cat *.sql | mysql -h mariadb.awscname.ap-southeast-1.rds.amazonaws.com -P 3306 -u root -p guacamole_db

systemctl restart tomcat9 guacd mysql


## Clean Up

To clean up and destroy the provisioned resources when you're done, run the following command:

terraform destroy

Confirm the destruction by typing "yes" when prompted.

## Conclusion

You have successfully deployed Apache Guacamole on an AWS EC2 instance, configured with an HTTPS ALB, SSL certificate, CloudWatch integration, MariaDB database, and automatic start/stop using EventBridge and Lambda. Enjoy using Apache Guacamole in your secure environment for remote desktop access!

Please note that this is a general guide, and you may need to adapt it to your specific requirements. Refer to the Terraform documentation and AWS documentation for further details and customization options.
