# CloudFormation Infrastructure Deployment

## Overview

This directory contains CloudFormation templates to deploy AWS infrastructure similar to the Terraform implementation, including:

- **VPC** with Public and Private Subnets
- **Internet Gateway** for Public Subnet
- **NAT Gateway** for Private Subnet
- **Route Tables** for both Public and Private Subnets
- **Security Groups** for securing EC2 instances
- **EC2 Instances** in both Public and Private Subnets

## Directory Structure

```
cloudformation/
├── main-stack.yaml              # Main CloudFormation stack (orchestrator)
├── parameters.json              # Parameters file
├── nested-stacks/              # Nested stack templates
│   ├── vpc-stack.yaml          # VPC, Subnets, Internet Gateway
│   ├── nat-stack.yaml          # NAT Gateway and Elastic IP
│   ├── route-tables-stack.yaml # Route Tables and associations
│   ├── security-groups-stack.yaml # Security Groups and rules
│   └── ec2-stack.yaml          # EC2 Instances
└── README.md                    # This file
```

## Prerequisites

### 1. AWS CLI Configured
```bash
aws configure
```

### 2. Create S3 Bucket for Nested Stack Templates

CloudFormation requires nested stacks to be uploaded to S3:

```bash
# Create S3 bucket (replace YOUR-BUCKET-NAME with your bucket name)
aws s3 mb s3://YOUR-BUCKET-NAME --region us-east-1

# Upload nested stack templates to S3
aws s3 cp nested-stacks/ s3://YOUR-BUCKET-NAME/cloudformation/nested-stacks/ --recursive
```

### 3. Create EC2 Key Pair

CloudFormation doesn't automatically create .pem files, you need to create the key pair first:

```bash
# Create key pair and save private key
aws ec2 create-key-pair --key-name mykey --query 'KeyMaterial' --output text > mykey.pem

# Set permissions for private key
chmod 400 mykey.pem
```

### 4. Update parameters.json

Edit the `parameters.json` file and change the values:

```json
{
  "ParameterKey": "NestedStacksS3Bucket",
  "ParameterValue": "YOUR-BUCKET-NAME-HERE"  # Replace with your S3 bucket name
},
{
  "ParameterKey": "AllowedIP",
  "ParameterValue": "YOUR-IP-HERE/32"  # Replace with your IP address
}
```

## Deployment Instructions

### Method 1: Deploy via AWS CLI

```bash
# Validate template first
aws cloudformation validate-template \
  --template-body file://main-stack.yaml

# Create stack with parameters from JSON file
aws cloudformation create-stack \
  --stack-name lab1-infrastructure \
  --template-body file://main-stack.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# Monitor deployment progress
aws cloudformation describe-stack-events \
  --stack-name lab1-infrastructure \
  --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]' \
  --output table

# View outputs
aws cloudformation describe-stacks \
  --stack-name lab1-infrastructure \
  --query 'Stacks[0].Outputs' \
  --output table
```

### Method 2: Deploy via AWS Console

1. Log in to AWS Console
2. Go to **CloudFormation** service
3. Click **Create stack** > **With new resources**
4. Select **Upload a template file** and upload `main-stack.yaml`
5. Enter Stack name: `lab1-infrastructure`
6. Fill in parameters (VpcCIDR, SubnetCIDR, AllowedIP, S3Bucket, etc.)
7. Click **Next** > **Next** > **Create stack**

## Verify Results

### 1. View Stack Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name lab1-infrastructure \
  --query 'Stacks[0].Outputs'
```

### 2. Check Created Resources

```bash
# VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=VPC"

# Subnets
aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public Subnet"

# EC2 Instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=Public Instance"

# Security Groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=Public Security Group"
```

### 3. SSH into Public EC2 Instance

```bash
# Get Public IP from stack outputs
PUBLIC_IP=$(aws cloudformation describe-stacks \
  --stack-name lab1-infrastructure \
  --query 'Stacks[0].Outputs[?OutputKey==`PublicInstancePublicIP`].OutputValue' \
  --output text)

# SSH into instance
ssh -i mykey.pem ubuntu@$PUBLIC_IP
```

## Delete Infrastructure

```bash
# Delete stack (will delete all resources)
aws cloudformation delete-stack --stack-name lab1-infrastructure

# Monitor deletion progress
aws cloudformation describe-stack-events \
  --stack-name lab1-infrastructure \
  --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType]' \
  --output table
```

**Note**: Deleting the stack will automatically delete all nested stacks and resources in the correct order.

## Validate Templates with cfn-lint

Install cfn-lint:
```bash
pip install cfn-lint
```

Validate templates:
```bash
# Validate main stack
cfn-lint main-stack.yaml

# Validate all nested stacks
cfn-lint nested-stacks/*.yaml
```

## Comparison with Terraform

| Aspect | Terraform | CloudFormation |
|--------|-----------|----------------|
| **Modules** | Local modules in `./modules/` | Nested stacks on S3 |
| **State** | S3 backend with DynamoDB lock | AWS managed automatically |
| **Destroy** | `terraform destroy` | `aws cloudformation delete-stack` |
| **Separated Rules** | `aws_security_group_rule` | `AWS::EC2::SecurityGroupIngress/Egress` |
| **Key Pair** | Auto-created with `tls_private_key` | Must create manually first |

## Troubleshooting

### Error: Template URL is not valid

- Check S3 bucket name in `parameters.json`
- Ensure nested stacks are uploaded to S3
- Verify S3 bucket permissions

### Error: Key pair does not exist

```bash
# Check key pair
aws ec2 describe-key-pairs --key-names mykey

# Create new if doesn't exist
aws ec2 create-key-pair --key-name mykey --query 'KeyMaterial' --output text > mykey.pem
chmod 400 mykey.pem
```

### Stack in ROLLBACK_COMPLETE State

```bash
# View detailed error
aws cloudformation describe-stack-events \
  --stack-name lab1-infrastructure \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'

# Delete failed stack and try again
aws cloudformation delete-stack --stack-name lab1-infrastructure
```

## Best Practices

1. **Always validate templates before deploying**
2. **Use cfn-lint to check for syntax errors**
3. **Upload nested stacks to S3 with versioning enabled**
4. **Use Change Sets to preview changes**
5. **Tag all resources for easy management**
6. **Backup parameters.json but don't commit sensitive data**

## References

- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [CloudFormation Best Practices](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html)
- [Nested Stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html)
