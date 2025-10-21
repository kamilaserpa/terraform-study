resource "aws_subnet" "subnet_public" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc_fiap.id
  cidr_block              = cidrsubnet(aws_vpc.vpc_fiap.cidr_block, 4, count.index) // 4 - máscara de rede /20, 4091 IPs disponíveis para usar, 4 bits. count representa o index
  map_public_ip_on_launch = true
  // A aws tem de A a F, porém a I não é útil, por isso litamos 
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]

  tags = var.tags
}
