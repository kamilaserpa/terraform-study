# Criando módulo a partir de configurações locais
module "ec2" {
  source = "../modules/ec2"

  ami           = data.aws_ami.ubuntu.id
  instance_name = var.instance_name
}

module "s3" {
  source = "../modules/s3"

  bucket_name = "fiap-modules-terraform"
}





# Criando um módulo a partir da lib em nuvem
#module "ec2-instance-complete" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "6.1.1"
#
#  # Altera o typo de instancia nas ec2 via variável, no módulo essa variável deve existir
#  INSTANCE_TYPE = "t4g.micro"
#}

#output "ec2_complete_arn" {
#    value = "arn"
#}
