#!/bin/bash

set -e

echo "========================================="
echo "CloudFormation Stack Deletion Script"
echo "========================================="
echo ""

STACK_NAME="lab1-infrastructure"
REGION="us-east-1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if stack exists
if ! aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &> /dev/null; then
    echo -e "${RED}Stack '$STACK_NAME' does not exist${NC}"
    exit 1
fi

# Confirm deletion
read -p "Are you sure you want to delete the stack '$STACK_NAME'? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deletion cancelled."
    exit 0
fi

echo -e "${YELLOW}Deleting stack...${NC}"
aws cloudformation delete-stack \
    --stack-name $STACK_NAME \
    --region $REGION

echo -e "${YELLOW}Waiting for stack deletion to complete...${NC}"
aws cloudformation wait stack-delete-complete \
    --stack-name $STACK_NAME \
    --region $REGION

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Stack deleted successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
