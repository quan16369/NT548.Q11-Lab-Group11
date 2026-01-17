# Lab 2 – Phần 2

## Triển khai hạ tầng AWS với CloudFormation và AWS CodePipeline

---

## 1. Mục tiêu

Phần này triển khai hạ tầng AWS bằng **CloudFormation**, quản lý mã nguồn bằng **AWS CodeCommit** và tự động hóa quá trình build & deploy bằng **AWS CodePipeline**, đáp ứng yêu cầu của Lab 2 – Phần 2.

Hạ tầng triển khai bao gồm:

* VPC
* Route Tables
* NAT Gateway
* EC2
* Security Groups

---

## 2. Chuẩn bị môi trường

### 2.1 Cấu hình AWS CLI

Trên máy local:

```bash
aws configure
```

Nhập:

* AWS Access Key ID
* AWS Secret Access Key
* Region: `us-east-1`
* Output format: `json`

---

## 3. Tạo repository CodeCommit

### 3.1 Tạo repository bằng AWS CLI

```bash
aws codecommit create-repository \
  --repository-name Lab2-CFN-Repo \
  --repository-description "CloudFormation Lab 2"
```

---

### 3.2 Thêm remote CodeCommit

```bash
git remote add codecommit https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Lab2-CFN-Repo
```

---

### 3.3 Cấu hình credential cho CodeCommit

#### Cách 1: Dùng Access Key & Secret Key

```bash
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
```

#### Cách 2 (thay thế):

* Vào **IAM → Users → Security credentials**
* Tạo **HTTPS Git credentials for AWS CodeCommit**
* Dùng username & password để đăng nhập Git

---

### 3.4 Push code lên CodeCommit

```bash
git push codecommit loc-dev
```

---

## 4. Chuẩn bị tài nguyên AWS

### 4.1 Tạo Key Pair

Tạo keypair với tên:

```
devops-key
```

---

### 4.2 Tạo IAM Role

Tạo các role sau:

* **CFN-Deploy-Role**

  * Dùng cho CloudFormation deploy stack

* **codebuild-Lab2-CFN-Build-service-role**

  * Gắn policy: `AmazonS3FullAccess`

---

### 4.3 Tạo S3 Bucket

Bucket dùng để lưu artifact:

```
nt548-terraform-state-1768057314
```

---

## 5. CloudFormation Template

### 5.1 Stack chính

* File: `main-stack.yaml`
* Stack name:

```
Lab2-CloudFormation-Stack
```

---

### 5.2 Template đóng gói

Sau khi package:

```
packaged-template.yaml
```

---

### 5.3 Tham số truyền vào stack

```json
{
  "KeyName": "devops-key",
  "AllowedIP": "0.0.0.0/0",
  "AMIId": "ami-0866a3c8686eaeeba",
  "AvailabilityZone": "us-east-1a"
}
```

---

## 6. AWS CodeBuild

### 6.1 Tạo CodeBuild project

Tên project:

```
Lab2-CFN-Build
```

Environment variables:

* `ARTIFACT_BUCKET` = `nt548-terraform-state-1768057314`

---

### 6.2 Chức năng CodeBuild

* Validate CloudFormation template
* Build và package template
* Xuất artifact cho pipeline

---

## 7. AWS CodePipeline

### 7.1 Tạo Pipeline

Tên pipeline:

```
Lab2-CFN-Pipeline
```

---

### 7.2 Các stage trong Pipeline

1. **Source**

   * Nguồn: CodeCommit
   * Repository: `Lab2-CFN-Repo`
   * Branch: `loc-dev`

2. **Build**

   * Dùng CodeBuild: `Lab2-CFN-Build`

3. **Deploy**

   * Dùng CloudFormation
   * Template: `packaged-template.yaml`
   * Role: `CFN-Deploy-Role`
   * Stack name: `Lab2-CloudFormation-Stack`

---

## 8. Kiểm tra kết quả triển khai

Sau khi pipeline chạy thành công:

* CloudFormation stack ở trạng thái `CREATE_COMPLETE`
* EC2 instance được tạo
* VPC, NAT Gateway, Route Tables, Security Groups tồn tại đúng cấu hình

---

## 9. Kết luận

Phần này đã hoàn thành:

* Quản lý mã CloudFormation bằng CodeCommit
* Tự động hóa build & deploy với CodePipeline
* Triển khai hạ tầng AWS đầy đủ theo yêu cầu Lab 2 – Phần 2

---

**Hoàn thành Lab 2 – Phần 2**
