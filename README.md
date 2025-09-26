# Terraform

É uma ferramenta de software de IaC (Infrastructure as Code).
Com ele você descreve sua infraestrutura em código (.tf), e o Terraform cria os recursos nos providers, AWS, GCP, Azure, etc.

Os usuários definem e fornecem infraestrutura de data center usando uma linguagem de configuração declarativa conhecida como HashiCorp Configuration Language (HCL).

Por exemplo, no lugar de clicar no console da AWS para criar uma VPC, EC2, S3, podemos escrever código com essas configurações e aplicá-lo.

Terraform documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs.

CLI documentation: https://developer.hashicorp.com/terraform/cli .

Instalação: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli .

## Declarando o provider
Podemos ver na [documentação](https://registry.terraform.io/browse/providers) o exemplo de criação de vários providers.

Para declarar um providder AWS criamos o arquivo [provider.tf](/provider.tf) com o conteúdo capturado da documentação (https://registry.terraform.io/providers/hashicorp/aws/latest/docs#example-usage):
```json
# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
```

Executamos `$ terraform init` e alguns arquivos são criados, podemos visualizar com:
```shel
$ ls -la
$ terraform show
```

## Bucket

Vamos criar um bucket S3, será declarado no arquivo [s3.tf](/s3.tf).
Podemos declarar mais de um bucket no arquivo, porém o nome do resource deve ser único, no exemplo "bucket", :
```json
//s3.tf
resource "aws_s3_bucket" "bucket" {
  bucket = "fiap-bucket-kamila-tf"

  tags = {
    Name        = "My primeiro bucket"
    Environment = "Terraform"
  }
}
```

Para implantar utilizamos o comando [plan](https://developer.hashicorp.com/terraform/cli/commands/plan) que exibe um preview do que será implantado. Em seguida o [apply](https://developer.hashicorp.com/terraform/cli/commands/apply),
```shell
$ terraform plan
$ terraform apply
```

Confirmamos com “yes", e podemos ver o bucket criado na AWS S3.

O comando [destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy) desprovisiona todos os objetos configirados pelo Terraform:
`$ terraform apply -destroy`.

## Tfstage
[terraform.tfstate](/terraform.tfstate) é um arquivo que mantém o estado, o versionamento do que foi criado anteriormente no provedor e informações sensíveis. Após o “apply” os arquivos terraform.tfstate e terraform.tfstate.backup sãqo criados, este último com informações sensíveis.
É importante manter esse arquivo para manter a administração de estruturas já criadas no provider.

### tfstate no S3
Podemos persistir o tfstate no aws S3. Pra isso vamos criar o bucket, alteramos o nosso arquivo s3.tf para:
```json
resource "aws_s3_bucket" "bucket-backend" {
  bucket = "tfstate-backend-kamila"

  tags = {
    Name        = "tfstate"
    Environment = "Production"
  }
}

resource "aws_s3_bucket" "bucket-aula" {
  provider = aws.sp
  bucket = "aula-2-kamila"
   # region = "sa-east-1" # Como estamos usando o provider de São Paulo essa propriedade não é necessário


  tags = {
    Name        = "aula2"
    Environment = "Develop"
  }
}
```

No arquivo provider.tf editamos para acessar a regiao de São Paulo. COmo essa região é paga, aqui foca o código de exemplo, porém vamos continuar utilizando us-east-1:
```json
provider "aws" {
  alias = "sp"
  region = "sa-east-1"
}
```

Se esse arquivo for corrompido ou perdido o provider vai perder a referência e entender que essa seria a primeira vez que os recursos estão sendo criados. Então se já houverem recursos com os mesmos nomes dá conflito e recursos podem ser perdidos.

## Backend
Criamos o recurso [backend S3](https://developer.hashicorp.com/terraform/language/backend/s3) que armazena o estado (tfstate) em um determinado bucket. O conteúdo do arquivo `terraform.tfstate` não ficará mais armazenado localmente, mas sim no bucket na WS S3. 

Quando inicializamos o terraform o backend é inicializado, por isso precisamos executar `$ terraform init -reconfigure`, plan e apply para implantar o backend. Podemos verificar que o conteúdo do arquivo local foi apagado e armazenado no S3.

![](/assets/backend-tfstate-s3.png)
