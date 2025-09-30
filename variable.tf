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
      "us-east-1", "us-west-2", "eu-west-1", 
      "ap-southeast-1", "sa-east-1"
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

variable "region_default" {
    default = "us-east-1"
}

variable "region_sp" {
    default = "sa-east-1"
}

# =============================================================================
# AWS CREDENTIALS VARIABLES
# =============================================================================

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition     = length(var.aws_access_key) >= 16 || var.aws_access_key == ""
    error_message = "AWS Access Key deve ter pelo menos 16 caracteres."
  }
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition     = length(var.aws_secret_key) >= 20 || var.aws_secret_key == ""
    error_message = "AWS Secret Key deve ter pelo menos 20 caracteres."
  }
}

variable "aws_session_token" {
  description = "AWS Session Token (para credenciais temporárias)"
  type        = string
  sensitive   = true
  default     = ""
}

