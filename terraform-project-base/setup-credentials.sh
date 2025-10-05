#!/bin/bash

# =============================================================================
# SCRIPT PARA CONFIGURAR CREDENCIAIS AWS PARA TERRAFORM
# =============================================================================

echo "🔧 Configurando credenciais AWS para Terraform..."

# Verificar se AWS CLI está instalado
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI encontrado!"
    echo "📋 Opções disponíveis:"
    echo "1. Usar AWS CLI (recomendado)"
    echo "2. Usar variáveis de ambiente"
    echo "3. Criar arquivo local"
    
    read -p "Escolha uma opção (1-3): " choice
    
    case $choice in
        1)
            echo "🔑 Configurando AWS CLI..."
            aws configure
            echo "✅ Credenciais configuradas no AWS CLI"
            echo "💡 O Terraform usará automaticamente essas credenciais"
            ;;
        2)
            echo "🔑 Configurando variáveis de ambiente..."
            read -p "Digite sua AWS Access Key: " access_key
            read -s -p "Digite sua AWS Secret Key: " secret_key
            echo ""
            
            export TF_VAR_aws_access_key="$access_key"
            export TF_VAR_aws_secret_key="$secret_key"
            
            echo "✅ Variáveis de ambiente configuradas"
            echo "💡 Execute: terraform plan"
            ;;
        3)
            echo "📁 Criando arquivo terraform.tfvars.local..."
            read -p "Digite sua AWS Access Key: " access_key
            read -s -p "Digite sua AWS Secret Key: " secret_key
            echo ""
            
            cat > terraform.tfvars.local << EOF
aws_access_key = "$access_key"
aws_secret_key = "$secret_key"
EOF
            
            echo "✅ Arquivo terraform.tfvars.local criado"
            echo "💡 Execute: terraform plan -var-file='terraform.tfvars.local'"
            ;;
        *)
            echo "❌ Opção inválida"
            exit 1
            ;;
    esac
else
    echo "❌ AWS CLI não encontrado"
    echo "📥 Instale o AWS CLI primeiro:"
    echo "   https://aws.amazon.com/cli/"
fi

echo ""
echo "🚀 Próximos passos:"
echo "   terraform init"
echo "   terraform plan"
echo "   terraform apply"
