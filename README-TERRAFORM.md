# Lab 2 – Phần 1

## Triển khai hạ tầng AWS với Terraform và GitHub Actions

---

## 1. Mục tiêu

Phần này triển khai hạ tầng AWS bằng **Terraform**, đồng thời tự động hóa quy trình kiểm tra và triển khai bằng **GitHub Actions**, đáp ứng các yêu cầu:

* Triển khai hạ tầng AWS:

  * VPC
  * Route Tables
  * NAT Gateway
  * EC2
  * Security Groups
* Tự động deploy bằng GitHub Actions
* Kiểm tra bảo mật & tuân thủ Terraform bằng **Checkov**

---

## 2. Cấu trúc thư mục liên quan

```bash
.
├── main.tf
├── variable.tf
├── outputs.tf
├── backend.tf
├── terraform.tfvars.example
├── modules/
│   ├── Vpc/
│   ├── Route-Tables/
│   ├── NAT-Gateway/
│   ├── Security-Groups/
│   └── EC2/
├── tests/
│   ├── VPC.tftest.hcl
│   ├── EC2.tftest.hcl
│   └── ...
└── .github/workflows/
    └── terraform-deploy.yml
```

---

## 3. Chuẩn bị môi trường

### 3.1 Cài đặt công cụ

Cần cài trên máy local hoặc EC2:

```bash
terraform -v
aws --version
git --version
```

Yêu cầu:

* Terraform >= 1.5
* AWS CLI v2

---

### 3.2 Cấu hình AWS Credentials

Cấu hình AWS CLI:

```bash
aws configure
```

Nhập:

* AWS Access Key
* AWS Secret Key
* Region (ví dụ: `us-east-1`)

Kiểm tra:

```bash
aws sts get-caller-identity
```

---

## 4. Chạy Terraform thủ công (Local)

### 4.1 Khởi tạo Terraform

```bash
terraform init
```

---

### 4.2 Kiểm tra plan

```bash
terraform plan
```

---

### 4.3 Triển khai hạ tầng

```bash
terraform apply
```

Xác nhận bằng `yes`.

---

### 4.4 Kiểm tra tài nguyên trên AWS

* AWS Console:

  * VPC
  * Subnets
  * Route Tables
  * NAT Gateway
  * EC2 Instances
  * Security Groups

---

## 5. Kiểm thử Terraform

### 5.1 Terraform Test

```bash
terraform test
```

Các test nằm trong thư mục:

```bash
tests/
```

---

## 6. Tự động hóa với GitHub Actions

### 6.1 Workflow

File workflow:

```bash
.github/workflows/terraform-deploy.yml
```

Workflow thực hiện:

1. Checkout code
2. Terraform Init
3. Terraform Validate
4. Terraform Plan
5. Chạy **Checkov**
6. Terraform Apply (nếu pass)

---

### 6.2 Kích hoạt GitHub Actions

* Push code lên GitHub repository
* Truy cập tab **Actions**
* Theo dõi pipeline chạy tự động

---

## 7. Kiểm tra bảo mật với Checkov

### 7.1 Mục đích

Checkov kiểm tra:

* Security best practices
* Compliance cho Terraform code

---

### 7.2 Checkov trong CI

Checkov được tích hợp trong GitHub Actions:

Ví dụ output:

* PASS / FAIL theo từng resource
* Các rule vi phạm được hiển thị chi tiết

---

## 8. Kiểm tra kết quả triển khai

### 8.1 GitHub Actions

* Pipeline status: **Success**
* Không có lỗi Checkov nghiêm trọng

---

### 8.2 AWS Console

* Hạ tầng được tạo đúng theo thiết kế
* EC2 chạy thành công
* NAT Gateway hoạt động

---

## 9. Hủy tài nguyên (Cleanup)

```bash
terraform destroy
```

Hoặc sử dụng script:

```bash
./safe-destroy.sh
```

---

## 10. Kết luận

Phần này hoàn thành yêu cầu:

* Sử dụng Terraform triển khai hạ tầng AWS
* Tự động hóa với GitHub Actions
* Tích hợp kiểm tra bảo mật bằng Checkov

---

**Hoàn thành Phần 1 – Lab 2**
