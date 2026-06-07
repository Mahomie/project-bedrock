terraform {
  backend "s3" {
    bucket  = "project-bedrock-tfstate-425221105441"
    key     = "project-bedrock/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
