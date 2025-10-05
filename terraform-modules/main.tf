module "ec2-instance-complete" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.1.1"

  # Altera o typo de instancia nas ec2 via variável, no módulo essa variável deve existir
  INSTANCE_TYPE = "t4g.micro"
}

output "ec2_complete_arn" {
    value = "arn"
}