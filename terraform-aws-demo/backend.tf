terraform {
  backend "s3" {
    bucket = "workflows-demo-tfstates"
    key    = "terraform/state/terraform.tfstate"
    region = "us-east-1"
  }
} 