resource "aws_s3_bucket" "bucket-backend" {
  bucket = "tfstate-backend-kamila"

  tags = {
    Name        = "tfstate"
    Environment = "Production"
  }
}

resource "aws_s3_bucket" "bucket-aula" {
# Using default provider (us-east-1) instead of sp provider (sa-east-1)
  bucket = var.bucket_name
  tags = var.tags_dev
}

resource "aws_s3_bucket" "bucket-aula-3" {
  bucket = "${var.bucket_name}-3"
  tags = var.tags_prod
}

# Cria um outro bucket uatilizando a propriedade do nome de um bucket não criado pelo terraform, já existente fiap_previouslly_created
# adicionando apenas um sulfixo "-3"
resource "aws_s3_bucket" "bucket-fiap_previouslly_created" {
  bucket = "${data.aws_s3_bucket.fiap_previouslly_created.bucket}-2"
  tags = var.tags_prod
}
