terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "aws" {
    region = var.region_default
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint # API server endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data) # Captura Autoridade Certificadora
  token                  = data.aws_eks_cluster_auth.auth.token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint # API server endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data) # Captura Autoridade Certificadora
  token                  = data.aws_eks_cluster_auth.auth.token
}
