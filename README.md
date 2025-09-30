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


## Principais comandos
 - `terraform init`
   - Primeiro a ser executado em um diretório terraform. Baixa os providers, configura o back-end para armazenar o estado, seja local ou remoto, verifica dependências e compatibilidade entre versões.
 - `terraform validate`
   - Verifica se o código de configuração (.tf files) está correto em termos de sintaxe e estrutura
 - `terraform plan`
   - gera e visualiza um plano de execução, mostra o que será alterado sem fazer alterações reais
   - `terraform plan -destroy -target="aws_s3_bucket.bucket-aula"` simula resultado da destruição de um recurso específico.
 - `terraform apply`
   - Executa o plano gerado pelo plan. Provisiona novos recursos, modifica os existentes, atualiza o arquivo tfstate. Solicita confirmação antes de executar, a menos que o par
   âmetro `-auto-approve`seja usado.
   - `-target` aplica apenas a recursos específicos
 - terraform show
   - Exibe informações detalhadas sobre o estado da infraestrutura, confirme o arquivo tfstate. Lista recursos gerenciados pelo terraform, com seus atributos e valores.
 - `terraform destroy`
   - Identifica todos os recursos do tfstate e emite comandos para destruie cada recurso de firna segura e ordenada.
 - `terraform output`
   - lê o arquivo tfstate e retorna os valores das variáveis do bloco `output`
 - `terraform refresh`
   - compara o estado registrado com a infraestrutura real e atualiza o arquivo tfstate para refletir o estado atual.
   - É usado quando mudanças foram feitas diretamente na infraestrutura para garantir que o estado reflita a realidade antes de executar novos planos.
 - `terraform state`
   - Permite alterar o estado diretamente, com comandos como mv, rm e list. É útil para reorganizar ou remover recursos sem alterar a infraestrutura
   - Usado para resolver problemas de estado corrompido e ao refatorar a configuração
 - `terraform fmt`
   - Formata o código terraform de acordo com os padrões do código HCL
 - `terraform graph`
   - Gera um gráfico das dependências entre recursos, cria uma representação em formato DOT.
   - Necessário download de ferramentas como Graphviz
   - Usado para entender a ordem de criação dos recursos e mapear dependências complexas
 - `terraform import`
   - Permite adicionar recursos existentes, criados anteriormente sem o terraform, à gestão do terraform. Atualiza o estado para incluir o recurso importado.
   - Usado para migrar recursos existentes para o gerenciamento do Terraform e durante integração de infraestrutura legada.
  
## Variables

Utilizamos [variables](https://developer.hashicorp.com/terraform/language/block/variable#background) para parametrizar configurações, tornando os módulos reusáveis e dinâmicos.
O recurso do terraform precisa ter um label único.

O bloco `variable` suporta os argumentos:
 - variable "<LABEL>"   block
 - type   type constraint
 - default   expression
 - description   string
 - validation   block
 - condition   expression
 - error_message   string
 - sensitive   boolean
 - nullable   boolean
 - ephemeral   boolean
  

### Definindo valores sensíveis
Não é recomendado deixar valores sensíveis no código, como senhas por exemplo. 

1. Variáveis de ambiente

Podemos definir variáveis de ambiente com o prefixo `TF_VAR_`.
No arquivo `.tf`: O nome da variável é o sulfixo, no exemplo abaixo "aws_access_key" (sem o TF_VAR_).


```shell
export TF_VAR_aws_access_key="AKIAIOSFODNN7EXAMPLE"
export TF_VAR_aws_secret_key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export TF_VAR_bucket_name="bucket-name"
```

2. AWS CLI (MELHOR PRÁTICA)

Outra opção é usar o AWS CLI (MELHOR PRÁTICA), pois o Terraform automaticamente detecta e usa as credenciais do AWS CLI.

```shell
# 1. Configurar AWS CLI uma vez
aws configure
```

3. Arquivos locais não commitados

Adicionar estes arquivos ao .gitignore.
Arquivo `terraform.tfvars.local`, que pode conter valores sensíveis mais configurações locais do desenvolvedor.

```hcl
# terraform.tfvars.local (já está no .gitignore)
aws_access_key = "AKIAIOSFODNN7EXAMPLE"
aws_secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
database_password = "minhasenha123"
```

Arquivo `secrets.tfvars`, usado apenas para valores sensíveis e secretos.

```shell
# secrets.tfvars (já está no .gitignore)
aws_access_key = "AKIAIOSFODNN7EXAMPLE"
aws_secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
database_password = "minhasenha123"
```

Para aplicar:
```bash
# Usar o arquivo específico
terraform plan -var-file="terraform.tfvars.local"
# ou
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars"
```

## Output

Output expõe valores dos recursos criados para outros módulos ou para o usuário após `terraform apply`, de recursos gerenciados pelo terraform local, assim nós capturamos o valor do console da AWS via código.
Outputs aparecem no final do terraform apply e podem ser consultados com terraform output.
No exemplo o ARN é o identificador único global de recursos AWS.

```json
output "bucket_arn" {
  value = aws_s3_bucket.bucket-aula.arn
  description = "ARN do bucket S3"
}
```

### Datasource
Data Source busca informações de recursos existentes na AWS (não cria novos recursos), acessa recursos que não foram criados pelo terraform.

Por exemplo, pode-se buscar AMI mais recente, pois é um valor mutável:

```json
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

No arquivo `.tf` podemos utilizar o valor do id do AMI por exemplo: `data.aws_ami.amazon_linux.id`.
O `$ terraform plan` exibe os atributos que podemos extrair do dado.
Precisamos de informações simples, que possamos lembrar, e únicas para que possamos buscar um recurso específico do provider.
