# =============================================================================
# GENERAL VARIABLES
# =============================================================================

variable "bucket_name" {
  description = "Nome do bucket S3 para desenvolvimento"
  type        = string
  default     = "kamila-lab-test"

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "O nome do bucket deve ter entre 3 e 63 caracteres."
  }
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
