data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Capturar o arn de um bucket no provider que não foi criado pelo terraform
data "aws_s3_bucket" "fiap_previouslly_created" {
  bucket = "bucket-fiap-created"
}