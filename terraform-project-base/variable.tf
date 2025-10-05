# =============================================================================
# GENERAL VARIABLES
# =============================================================================

# REGEX
variable "bucket_name" {
  description = "Nome do bucket S3 para desenvolvimento"
  default     = "kamila-lab-2025"
}

output "regex_bucket" {
  value = regex("kamila-lab-(\\d+)", var.bucket_name)
}

# REGEX_ALL
variable "bucket_name_list" {
  default = "kamila-lab-2025,kamila-lab-2026,kamila-lab-2027"
}

output "regex_bucket" {
  value = regexall("kamila-lab-(\\d+)", var.bucket_name_list)
}

# LENGTH
variable "bucket_name_length" {
  default = "kamila-aula-fiap-2025-prod"
}

# Obriga que um padrão de nome seja respoeitado na criação de um bucket por exemplo
output "regex_bucket" {
  value = length(regexall("^[a-z0-9]+-(aula|live)+-(fiap|alura)+-[0-9]+-(prod|stage|dev)$", var.bucket_name_length))
}

variable "region_default" {
  description = "Região AWS padrão para recursos"
  type        = string
  default     = "us-east-1"

  validation {
    condition = contains([
      "us-east-1"
    ], var.region_default)
    error_message = "A região deve ser uma das regiões AWS suportadas."
  }
}

variable "region_sp" {
  description = "Região AWS para São Paulo"
  type        = string
  default     = "sa-east-1"
}

# =============================================================================
# TAGS VARIABLES
# =============================================================================

variable "tags_dev" {
  description = "Tags padrão para recursos de desenvolvimento"
  type        = map(string)
  default = {
    Name        = "aula2"
    Environment = "Development"
    Project     = "terraform-study"
    Owner       = "kamila"
    ManagedBy   = "terraform"
  }
}

variable "tags_prod" {
  description = "Tags padrão para recursos de produção"
  type        = map(string)
  default = {
    Name        = "aula3"
    Environment = "Production"
    Project     = "terraform-study"
    Owner       = "kamila"
    ManagedBy   = "terraform"
    Fiap        = "postech"
  }
}

variable "instance_type" {
  default = "t2.micro"
}
