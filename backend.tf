terraform {
  backend "s3" {
    bucket = "tfstate-backend-kamila"
    key    = "fiap/terraform-tfstate"
    region = "us-east-1"
  }
}
