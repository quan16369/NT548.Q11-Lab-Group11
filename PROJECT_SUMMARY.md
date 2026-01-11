# Lab 1 Infrastructure - Project Summary

## ✅ Hoàn thành

### 1. Terraform Implementation (100%)
- ✅ VPC với Public/Private Subnets
- ✅ Internet Gateway và NAT Gateway
- ✅ Route Tables (Public & Private)
- ✅ Security Groups (với rules tách riêng - fix circular dependency)
- ✅ EC2 Instances (Public & Private)
- ✅ Module structure hoàn chỉnh
- ✅ S3 Backend với DynamoDB locking
- ✅ Terraform native tests
- ✅ Documentation (README.md, TESTING.md)
- ✅ Safe destroy script

### 2. CloudFormation Implementation (100%)
- ✅ VPC Stack (nested stack)
- ✅ NAT Gateway Stack
- ✅ Route Tables Stack
- ✅ Security Groups Stack (với rules tách riêng)
- ✅ EC2 Stack
- ✅ Main orchestrator stack
- ✅ Deployment scripts (deploy.sh, destroy.sh, validate.sh)
- ✅ Parameters file
- ✅ Documentation (cloudformation/README.md)

## Cấu trúc Project

```
Lab1_Infrastructure/
├── Terraform Implementation (Root)
│   ├── main.tf, backend.tf, outputs.tf, variable.tf
│   ├── modules/
│   │   ├── Vpc/
│   │   ├── NAT-Gateway/
│   │   ├── Route-Tables/
│   │   ├── Security-Groups/     # ✅ Rules tách riêng
│   │   └── EC2/
│   ├── tests/
│   │   └── *.tftest.hcl
│   ├── simple-validation.tftest.hcl
│   ├── safe-destroy.sh          # ✅ Script xóa an toàn
│   ├── TESTING.md
│   └── README.md
│
└── CloudFormation Implementation
    └── cloudformation/
        ├── main-stack.yaml
        ├── nested-stacks/
        │   ├── vpc-stack.yaml
        │   ├── nat-stack.yaml
        │   ├── route-tables-stack.yaml
        │   ├── security-groups-stack.yaml   # ✅ Rules tách riêng
        │   └── ec2-stack.yaml
        ├── parameters.json
        ├── deploy.sh
        ├── destroy.sh
        ├── validate.sh
        └── README.md
```

## Key Improvements

### 1. Security Groups - Tách riêng Rules
**Vấn đề**: Inline rules gây circular dependency → Terraform/CloudFormation destroy bị kẹt

**Giải pháp**:
- **Terraform**: Dùng `aws_security_group_rule` resources riêng biệt
- **CloudFormation**: Dùng `AWS::EC2::SecurityGroupIngress/Egress` resources riêng biệt

**Kết quả**: 
- ✅ Destroy không còn bị "Still destroying..."
- ✅ AWS có thể xóa rules trước, sau đó xóa security groups
- ✅ Không còn deadlock

### 2. Safe Destroy Script (Terraform)
Script xóa resources theo thứ tự đúng:
1. EC2 instances
2. Security Groups
3. NAT Gateway
4. Route Tables
5. VPC và các resources còn lại

### 3. CloudFormation Nested Stacks
- Nested stacks upload lên S3
- Main stack orchestrates tất cả nested stacks
- Automatic dependency management
- Clean separation of concerns

## Deployment Instructions

### Terraform
```bash
# Deploy
terraform init
terraform plan
terraform apply -auto-approve

# Destroy
./safe-destroy.sh
```

### CloudFormation
```bash
cd cloudformation/

# Deploy
./deploy.sh YOUR-S3-BUCKET-NAME

# Destroy
./destroy.sh
```

## Testing

### Terraform
```bash
# Validation test (không tạo resources mới)
terraform test simple-validation.tftest.hcl

# Clean-room tests (chỉ chạy khi chưa deploy)
terraform test tests/VPC.tftest.hcl
```

### CloudFormation
```bash
cd cloudformation/

# Validate templates
./validate.sh

# Or with cfn-lint
cfn-lint main-stack.yaml
cfn-lint nested-stacks/*.yaml
```

## Compliance với Đề Bài

### NT548-BaiTapThucHanh-01 Requirements:

#### ✅ Các dịch vụ cần triển khai (10 điểm):
- [x] VPC với Subnets (Public + Private) - 3 điểm
- [x] Internet Gateway - 3 điểm
- [x] Default Security Group - 3 điểm
- [x] Route Tables (Public + Private) - 2 điểm
- [x] NAT Gateway - 1 điểm
- [x] EC2 Instances (Public + Private) - 2 điểm
- [x] Security Groups (Public + Private) - 2 điểm

#### ✅ Yêu cầu kỹ thuật:
- [x] Viết dưới dạng **module** (Terraform) / **nested stacks** (CloudFormation)
- [x] Đảm bảo **an toàn bảo mật** cho EC2 (Security Groups rules)
- [x] **Test cases** để kiểm tra từng dịch vụ
- [x] **README** hướng dẫn cách chạy
- [x] **Cả Terraform VÀ CloudFormation**

#### ✅ Kết quả nộp bài:
- [x] Link GitHub với source code
- [x] README.md đầy đủ
- [ ] Báo cáo Word (cần làm tiếp)

## Next Steps

### Cần làm tiếp:
1. **Báo cáo Word** theo template NT548-BaiTapThucHanh-01
2. Test deployment thực tế với AWS credentials mới
3. Screenshot kết quả deploy (cho báo cáo)
4. Push code lên GitHub

### Optional Improvements:
- [ ] GitHub Actions CI/CD cho Terraform
- [ ] AWS CodePipeline cho CloudFormation
- [ ] Checkov security scanning
- [ ] Taskcat testing cho CloudFormation

## Resources Created

Cả hai phương pháp đều tạo:
- 1 VPC
- 2 Subnets (Public + Private)
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Elastic IP (cho NAT)
- 2 Route Tables
- 2 Route Table Associations
- 3 Security Groups (Default + Public + Private)
- 6+ Security Group Rules
- 2 EC2 Instances
- 1 Key Pair

**Total: ~23 resources**

## Git Repository Status
- ✅ `.gitignore` configured
- ✅ `.pem` files excluded
- ✅ `terraform.tfvars` excluded
- ✅ `local.tf` excluded
- ✅ Git history clean (no leaked credentials)
