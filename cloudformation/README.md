# CloudFormation Infrastructure Deployment

## Tổng quan

Thư mục này chứa các CloudFormation templates để triển khai infrastructure AWS tương tự như phần Terraform, bao gồm:

- **VPC** với Public và Private Subnets
- **Internet Gateway** cho Public Subnet
- **NAT Gateway** cho Private Subnet
- **Route Tables** cho cả Public và Private Subnets
- **Security Groups** để bảo mật EC2 instances
- **EC2 Instances** trong cả Public và Private Subnets

## Cấu trúc thư mục

```
cloudformation/
├── main-stack.yaml              # Main CloudFormation stack (orchestrator)
├── parameters.json              # Parameters file
├── nested-stacks/              # Nested stack templates
│   ├── vpc-stack.yaml          # VPC, Subnets, Internet Gateway
│   ├── nat-stack.yaml          # NAT Gateway và Elastic IP
│   ├── route-tables-stack.yaml # Route Tables và associations
│   ├── security-groups-stack.yaml # Security Groups và rules
│   └── ec2-stack.yaml          # EC2 Instances
└── README.md                    # This file
```

## Yêu cầu trước khi triển khai

### 1. AWS CLI đã được cấu hình
```bash
aws configure
```

### 2. Tạo S3 bucket để lưu nested stack templates

CloudFormation yêu cầu nested stacks phải được upload lên S3:

```bash
# Tạo S3 bucket (thay YOUR-BUCKET-NAME bằng tên bucket của bạn)
aws s3 mb s3://YOUR-BUCKET-NAME --region us-east-1

# Upload nested stack templates lên S3
aws s3 cp nested-stacks/ s3://YOUR-BUCKET-NAME/cloudformation/nested-stacks/ --recursive
```

### 3. Tạo EC2 Key Pair

CloudFormation không tự động tạo file .pem, bạn cần tạo key pair trước:

```bash
# Tạo key pair và lưu private key
aws ec2 create-key-pair --key-name mykey --query 'KeyMaterial' --output text > mykey.pem

# Đặt quyền cho private key
chmod 400 mykey.pem
```

### 4. Cập nhật parameters.json

Sửa file `parameters.json` và thay đổi các giá trị:

```json
{
  "ParameterKey": "NestedStacksS3Bucket",
  "ParameterValue": "YOUR-BUCKET-NAME-HERE"  # Thay bằng tên S3 bucket của bạn
},
{
  "ParameterKey": "AllowedIP",
  "ParameterValue": "YOUR-IP-HERE/32"  # Thay bằng IP của bạn
}
```

## Cách triển khai

### Phương pháp 1: Deploy bằng AWS CLI

```bash
# Validate template trước
aws cloudformation validate-template \
  --template-body file://main-stack.yaml

# Create stack với parameters từ file JSON
aws cloudformation create-stack \
  --stack-name lab1-infrastructure \
  --template-body file://main-stack.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# Theo dõi quá trình deploy
aws cloudformation describe-stack-events \
  --stack-name lab1-infrastructure \
  --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]' \
  --output table

# Xem outputs
aws cloudformation describe-stacks \
  --stack-name lab1-infrastructure \
  --query 'Stacks[0].Outputs' \
  --output table
```

### Phương pháp 2: Deploy bằng AWS Console

1. Đăng nhập AWS Console
2. Vào **CloudFormation** service
3. Click **Create stack** > **With new resources**
4. Chọn **Upload a template file** và upload `main-stack.yaml`
5. Nhập Stack name: `lab1-infrastructure`
6. Điền các parameters (VpcCIDR, SubnetCIDR, AllowedIP, S3Bucket, etc.)
7. Click **Next** > **Next** > **Create stack**

## Kiểm tra kết quả

### 1. Xem stack outputs

```bash
aws cloudformation describe-stacks \
  --stack-name lab1-infrastructure \
  --query 'Stacks[0].Outputs'
```

### 2. Kiểm tra resources đã tạo

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

### 3. SSH vào Public EC2 Instance

```bash
# Lấy Public IP từ stack outputs
PUBLIC_IP=$(aws cloudformation describe-stacks \
  --stack-name lab1-infrastructure \
  --query 'Stacks[0].Outputs[?OutputKey==`PublicInstancePublicIP`].OutputValue' \
  --output text)

# SSH vào instance
ssh -i mykey.pem ubuntu@$PUBLIC_IP
```

## Xóa infrastructure

```bash
# Delete stack (sẽ xóa tất cả resources)
aws cloudformation delete-stack --stack-name lab1-infrastructure

# Theo dõi quá trình xóa
aws cloudformation describe-stack-events \
  --stack-name lab1-infrastructure \
  --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType]' \
  --output table
```

**Lưu ý**: Xóa stack sẽ tự động xóa tất cả nested stacks và resources theo thứ tự đúng.

## Validate templates với cfn-lint

Install cfn-lint:
```bash
pip install cfn-lint
```

Validate templates:
```bash
# Validate main stack
cfn-lint main-stack.yaml

# Validate tất cả nested stacks
cfn-lint nested-stacks/*.yaml
```

## So sánh với Terraform

| Khía cạnh | Terraform | CloudFormation |
|-----------|-----------|----------------|
| **Modules** | Local modules trong `./modules/` | Nested stacks trên S3 |
| **State** | S3 backend với DynamoDB lock | AWS quản lý tự động |
| **Destroy** | `terraform destroy` | `aws cloudformation delete-stack` |
| **Rules tách riêng** | `aws_security_group_rule` | `AWS::EC2::SecurityGroupIngress/Egress` |
| **Key Pair** | Tạo tự động với `tls_private_key` | Phải tạo thủ công trước |

## Troubleshooting

### Lỗi: Template URL is not valid

- Kiểm tra S3 bucket name trong `parameters.json`
- Đảm bảo đã upload nested stacks lên S3
- Kiểm tra S3 bucket permissions

### Lỗi: Key pair does not exist

```bash
# Kiểm tra key pair
aws ec2 describe-key-pairs --key-names mykey

# Tạo mới nếu chưa có
aws ec2 create-key-pair --key-name mykey --query 'KeyMaterial' --output text > mykey.pem
chmod 400 mykey.pem
```

### Stack bị ROLLBACK_COMPLETE

```bash
# Xem lỗi chi tiết
aws cloudformation describe-stack-events \
  --stack-name lab1-infrastructure \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'

# Xóa stack lỗi và thử lại
aws cloudformation delete-stack --stack-name lab1-infrastructure
```

## Best Practices

1. **Luôn validate template trước khi deploy**
2. **Sử dụng cfn-lint để check lỗi syntax**
3. **Upload nested stacks lên S3 với versioning enabled**
4. **Sử dụng Change Sets để preview changes**
5. **Tag tất cả resources để dễ quản lý**
6. **Backup parameters.json nhưng không commit sensitive data**

## Tài liệu tham khảo

- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [CloudFormation Best Practices](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html)
- [Nested Stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html)
