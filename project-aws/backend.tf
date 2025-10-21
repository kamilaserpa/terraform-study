terraform {
  backend "s3" {
    bucket = "fiap-aula-terraform-kamila"
    key    = "fiap-aula-aws/terraform.tfstate"
    region = "us-east-1"
  }
}
