resource "aws_s3_bucket" "bucket-backend" {
  bucket = "tfstate-backend-kamila"

  tags = {
    Name        = "tfstate"
    Environment = "Production"
  }
}

#resource "aws_s3_bucket" "bucket-aula" {
#  # Using default provider (us-east-1) instead of sp provider (sa-east-1)
#  bucket = "kamila-lab-test"
#
#  tags = {
#    Name        = "aula2"
#    Environment = "Develop"
#  }
#}
