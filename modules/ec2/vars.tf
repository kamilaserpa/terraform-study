variable "ami" {
    description = "Insira o ID da ami usada na ec2"
}

variable "instance_type" {
    description = "Valor usado para o tipo de instância"
    default = "t2.micro"
}

variable "instance_name" {
    description = "Nome definido para a instancia"
}

variable "region_default" {
    description = "Insira o valor da região onde o recurso será criado"
    default = "us-east-1"
}
