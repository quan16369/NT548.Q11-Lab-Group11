provider "aws" {
  region = "ap-southeast-1"  # Edit according to your region
  access_key = run.setup.access_key
  secret_key = run.setup.secret_key
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

# Run the tests
run "unit_test" {
  command = apply

  # Check outputs
  assert {
    condition = module.VPC.vpc_id != ""
    error_message = "The VPC ID should not be empty."
  }
  assert {
    condition = module.VPC.public_subnet_id != ""
    error_message = "The public_subnet_id should not be empty."
  }
  assert {
    condition = module.VPC.private_subnet_id != ""
    error_message = "The private_subnet_id should not be empty."
  }
  assert { 
    condition = module.VPC.internet_gateway_id  != ""
    error_message = "The internet_gateway_id should not be empty."
  }
}