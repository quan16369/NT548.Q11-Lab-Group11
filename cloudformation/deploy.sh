#!/bin/bash

set -e

echo "========================================="
echo "CloudFormation Deployment Script"
echo "========================================="
echo ""

# Configuration
STACK_NAME="lab1-infrastructure"
REGION="us-east-1"
S3_BUCKET=""
NESTED_STACK_PREFIX="cloudformation/nested-stacks/"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if S3 bucket name is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: S3 bucket name is required${NC}"
    echo "Usage: ./deploy.sh YOUR-S3-BUCKET-NAME"
    echo ""
    echo "Example: ./deploy.sh my-cloudformation-templates-bucket"
    exit 1
fi

S3_BUCKET=$1

echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials not configured. Please run 'aws configure'${NC}"
    exit 1
fi

echo -e "${GREEN}✓ AWS CLI configured${NC}"

# Check if key pair exists
echo -e "${YELLOW}Step 2: Checking EC2 Key Pair...${NC}"
if ! aws ec2 describe-key-pairs --key-names mykey --region $REGION &> /dev/null; then
    echo -e "${RED}Key pair 'mykey' does not exist.${NC}"
    read -p "Do you want to create it? (yes/no): " create_key
    if [ "$create_key" = "yes" ]; then
        aws ec2 create-key-pair --key-name mykey --region $REGION --query 'KeyMaterial' --output text > mykey.pem
        chmod 400 mykey.pem
        echo -e "${GREEN}✓ Key pair created and saved to mykey.pem${NC}"
    else
        echo -e "${RED}Deployment cancelled.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Key pair 'mykey' exists${NC}"
fi

# Check if S3 bucket exists
echo -e "${YELLOW}Step 3: Checking S3 bucket...${NC}"
if ! aws s3 ls "s3://${S3_BUCKET}" --region $REGION &> /dev/null; then
    echo -e "${YELLOW}S3 bucket does not exist. Creating...${NC}"
    aws s3 mb "s3://${S3_BUCKET}" --region $REGION
    echo -e "${GREEN}✓ S3 bucket created${NC}"
else
    echo -e "${GREEN}✓ S3 bucket exists${NC}"
fi

# Upload nested stacks to S3
echo -e "${YELLOW}Step 4: Uploading nested stack templates to S3...${NC}"
aws s3 cp nested-stacks/ "s3://${S3_BUCKET}/${NESTED_STACK_PREFIX}" --recursive --region $REGION
echo -e "${GREEN}✓ Nested stacks uploaded${NC}"

# Update parameters file with S3 bucket name
echo -e "${YELLOW}Step 5: Updating parameters file...${NC}"
cat > parameters.json << EOF
[
  {
    "ParameterKey": "VpcCIDR",
    "ParameterValue": "10.0.0.0/16"
  },
  {
    "ParameterKey": "PublicSubnetCIDR",
    "ParameterValue": "10.0.1.0/24"
  },
  {
    "ParameterKey": "PrivateSubnetCIDR",
    "ParameterValue": "10.0.2.0/24"
  },
  {
    "ParameterKey": "AvailabilityZone",
    "ParameterValue": "us-east-1a"
  },
  {
    "ParameterKey": "AllowedIP",
    "ParameterValue": "112.197.32.245/32"
  },
  {
    "ParameterKey": "AMIId",
    "ParameterValue": "ami-0866a3c8686eaeeba"
  },
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t2.micro"
  },
  {
    "ParameterKey": "KeyName",
    "ParameterValue": "mykey"
  },
  {
    "ParameterKey": "NestedStacksS3Bucket",
    "ParameterValue": "${S3_BUCKET}"
  },
  {
    "ParameterKey": "NestedStacksS3KeyPrefix",
    "ParameterValue": "${NESTED_STACK_PREFIX}"
  }
]
EOF
echo -e "${GREEN}✓ Parameters file updated${NC}"

# Validate template
echo -e "${YELLOW}Step 6: Validating CloudFormation template...${NC}"
aws cloudformation validate-template \
    --template-body file://main-stack.yaml \
    --region $REGION > /dev/null
echo -e "${GREEN}✓ Template is valid${NC}"

# Check if stack already exists
echo -e "${YELLOW}Step 7: Checking if stack exists...${NC}"
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &> /dev/null; then
    echo -e "${YELLOW}Stack already exists. Updating...${NC}"
    aws cloudformation update-stack \
        --stack-name $STACK_NAME \
        --template-body file://main-stack.yaml \
        --parameters file://parameters.json \
        --capabilities CAPABILITY_IAM \
        --region $REGION

    echo -e "${YELLOW}Waiting for stack update to complete...${NC}"
    aws cloudformation wait stack-update-complete \
        --stack-name $STACK_NAME \
        --region $REGION
    echo -e "${GREEN}✓ Stack updated successfully${NC}"
else
    echo -e "${YELLOW}Creating new stack...${NC}"
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body file://main-stack.yaml \
        --parameters file://parameters.json \
        --capabilities CAPABILITY_IAM \
        --region $REGION

    echo -e "${YELLOW}Waiting for stack creation to complete (this may take 5-10 minutes)...${NC}"
    aws cloudformation wait stack-create-complete \
        --stack-name $STACK_NAME \
        --region $REGION
    echo -e "${GREEN}✓ Stack created successfully${NC}"
fi

# Display outputs
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}Stack Outputs:${NC}"
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table

echo ""
echo -e "${YELLOW}To SSH into the Public EC2 instance:${NC}"
PUBLIC_IP=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`PublicInstancePublicIP`].OutputValue' \
    --output text)
echo "ssh -i mykey.pem ubuntu@${PUBLIC_IP}"
