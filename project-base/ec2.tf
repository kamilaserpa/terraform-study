
resource "aws_instance" "web_count" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = var.tags_prod
}

resource "aws_instance" "web_for_each_toset" {
  for_each      = toset(["t3.medium","t3.micro","t3.nano"])
  ami           = data.aws_ami.ubuntu.id
  instance_type = each.key

  tags = {
    Name = each.key
  }
}

resource "aws_instance" "web_for_each" {
  for_each      = var.instance_type_list
  ami           = data.aws_ami.ubuntu.id
  instance_type = each.key

  tags = {
    Name = each.value
  }
}

variable "instance_type_list" {
  default = {
    "t3.medium" = "FIAP-medium",
    "t3.micro" = "FIAP-micro",
    "t3.nano" = "FIAP-nano"
  }
}
