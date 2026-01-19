# Lab 2 – Quản lý và triển khai hạ tầng AWS và ứng dụng Microservices

## 1. Giới thiệu

Bài Lab 2 tập trung vào việc quản lý và tự động hóa triển khai hạ tầng AWS cũng như ứng dụng microservices bằng các công cụ DevOps phổ biến, bao gồm:

* **Terraform + GitHub Actions + Checkov**
* **CloudFormation + AWS CodePipeline + CodeBuild**
* **Jenkins CI/CD + Docker + Kubernetes (EKS) + SonarQube + Trivy**

Toàn bộ mã nguồn được tổ chức trong một repository duy nhất, mỗi phần có README riêng mô tả chi tiết cách triển khai.

---

## 2. Kiến trúc tổng thể

Lab 2 gồm **3 phần độc lập**, tương ứng với yêu cầu đề bài:

### Phần 1 – Terraform + GitHub Actions

* Triển khai hạ tầng AWS: VPC, Route Tables, NAT Gateway, EC2, Security Groups
* Tự động hóa deploy bằng GitHub Actions
* Kiểm tra bảo mật Terraform bằng **Checkov**

📁 Thư mục chính:

```
/
├── main.tf
├── modules/
├── tests/
└── .github/workflows/terraform-deploy.yml
```

👉 Chi tiết xem tại: **README-TERRAFORM.md**

---

### Phần 2 – CloudFormation + AWS CodePipeline

* Triển khai hạ tầng AWS tương tự phần 1 bằng CloudFormation (nested stacks)
* Kiểm tra template bằng **cfn-lint** và **taskcat**
* Tự động build & deploy bằng **AWS CodePipeline + CodeBuild**

📁 Thư mục chính:

```
cloudformation/
├── main-stack.yaml
├── nested-stacks/
└── buildspec.yml
```

👉 Chi tiết xem tại: **cloudformation/README.md**

---

### Phần 3 – Jenkins CI/CD cho Microservices

* Ứng dụng microservices gồm `user-service` và `product-service`
* Jenkins tự động:

  * Build
  * Test
  * SonarQube scan
  * Build & push Docker image
  * Security scan bằng Trivy
  * Deploy lên Kubernetes (EKS)

📁 Thư mục chính:

```
microservices/
├── Jenkinsfile
├── user-service/
├── product-service/
└── k8s/
```

👉 Chi tiết xem tại: **microservices/README.md**

---

## 3. Yêu cầu môi trường chung

### 3.1 Tài khoản & quyền

* AWS Account
* IAM User / Role có quyền:

  * EC2, VPC, IAM
  * CloudFormation
  * EKS
  * S3, CodePipeline, CodeBuild

### 3.2 Công cụ cài đặt trên máy local / EC2

* AWS CLI
* Terraform
* Git
* Docker
* kubectl
* eksctl
* Jenkins
* SonarQube
* Trivy

---

## 4. Cách chạy nhanh từng phần

### Chạy Terraform (Phần 1)

```bash
terraform init
terraform plan
terraform apply
```

Hoặc trigger GitHub Actions bằng cách push code lên repository.

---

### Chạy CloudFormation (Phần 2)

```bash
cd cloudformation
./validate.sh
./deploy.sh
```

Hoặc chạy tự động qua AWS CodePipeline.

---

### Chạy Jenkins Pipeline (Phần 3)

1. Truy cập Jenkins Dashboard
2. Tạo pipeline từ `microservices/Jenkinsfile`
3. Build pipeline
4. Kiểm tra:

   * SonarQube Dashboard
   * DockerHub images
   * Kubernetes pods & services

---

## 5. Kiểm tra kết quả triển khai

* **AWS Console**

  * VPC, EC2, NAT Gateway
  * CloudFormation stacks
  * EKS Cluster & Node Groups

* **Jenkins**

  * Pipeline stages thành công

* **SonarQube**

  * Code quality report cho microservices

* **DockerHub**

  * Images được push thành công

* **Kubernetes**

```bash
kubectl get nodes
kubectl get pods
kubectl get svc
```

---

## 6. Tài liệu chi tiết

| Phần                          | File README              |
| ----------------------------- | ------------------------ |
| Terraform + GitHub Actions    | README-TERRAFORM.md      |
| CloudFormation + CodePipeline | cloudformation/README.md |
| Jenkins + Microservices       | microservices/README.md  |

---

**Hoàn thành Lab 2 – NT548**
