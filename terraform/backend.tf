

terraform {
  backend "s3" {
    bucket         = "meu-eks-terraform-state"
    key            = "postgres/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "meu-eks-terraform-lock-001"
    encrypt        = true
  }
}