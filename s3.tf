resource "aws_s3_bucket" "bucket-backend" {
  bucket = "tfstate-backend-kamila"

  tags = {
    Name        = "tfstate"
    Environment = "Production"
  }
}

resource "aws_s3_bucket" "bucket-aula" {
  provider = aws.sp
  bucket = "aula-2-kamila"

  tags = {
    Name        = "aula2"
    Environment = "Develop"
  }
}