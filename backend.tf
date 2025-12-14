terraform {
  backend "s3" {
    bucket =  "terraform-bucket"       # name of the S3 bucket
    key    =  "dev/terraform.tfstate"         # path to the state file inside the bucket
    region =  "us-east-1"                     # region of the S3 bucket
    encrypt = true                           # enable server-side encryption
    dynamodb_table = "terraform-state-lock"

  }
}