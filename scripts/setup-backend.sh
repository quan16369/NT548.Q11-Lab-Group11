# Create S3 bucket for state
aws s3 mb s3://nt548-terraform-state-$(date +%s) --region ap-southeast-1
aws s3api put-bucket-versioning \
  --bucket nt548-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table fore locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-southeast-1
