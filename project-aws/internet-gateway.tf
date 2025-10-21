resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_fiap.index
}

/* // Configuração desnecessária
resource "aws_internet_gateway_attachment" "igw_attach" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id = aws_vpc.vpc_fiap.id
}
*/
