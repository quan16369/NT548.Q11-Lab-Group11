terraform {
  backend "s3" {
    bucket =  "nt548-terraform-state-1768057314"       # name of the S3 bucket
    key    =  "dev/terraform.tfstate"         # path to the state file inside the bucket
    region =  "us-east-1"                     # region of the S3 bucket
    encrypt = true                           # enable server-side encryption
    use_lockfile = true
    # dynamodb_table = "terraform-state-lock"

  }
}