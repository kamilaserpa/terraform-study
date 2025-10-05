variable "bucket_name" {
    description = "Insira um nome pata o bucket"
}

variable "acl" {
    description = "Insira a acl usada no bucket"
    default = "private"
}

variable "region_default" {
    description = "Insira o valor da região onde o recurso será criado"
    default = "us-east-1"
}
