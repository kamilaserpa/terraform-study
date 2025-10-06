# Terraform

É uma ferramenta de software de IaC (Infrastructure as Code).
Com ele você descreve sua infraestrutura em código (.tf), e o Terraform cria os recursos nos providers, AWS, GCP, Azure, etc.

Os usuários definem e fornecem infraestrutura de data center usando uma linguagem de configuração declarativa conhecida como HashiCorp Configuration Language (HCL).

Por exemplo, no lugar de clicar no console da AWS para criar uma VPC, EC2, S3, podemos escrever código com essas configurações e aplicá-lo.

## Índice

- [Terraform](#terraform)
  - [Índice](#índice)
  - [Documentation](#documentation)
  - [Declarando o provider](#declarando-o-provider)
  - [Bucket](#bucket)
  - [Tfstage](#tfstage)
    - [tfstate no S3](#tfstate-no-s3)
  - [Backend](#backend)
  - [Principais comandos](#principais-comandos)
  - [Variables](#variables)
    - [Definindo valores sensíveis](#definindo-valores-sensíveis)
  - [Output](#output)
  - [Datasource](#datasource)
  - [Locals](#locals)
  - [Module](#module)
    - [Criando módulo](#criando-módulo)
  - [Loops](#loops)
    - [1. count](#1-count)
    - [2. for\_each](#2-for_each)
    - [3. for expression (listas/mapas dentro de locals)](#3-for-expression-listasmapas-dentro-de-locals)
    - [Expressões regex](#expressões-regex)
    - [Regexall](#regexall)

## Documentation
Terraform documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs.

CLI documentation: https://developer.hashicorp.com/terraform/cli .

Instalação: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli.

## Declarando o provider
Podemos ver na [documentação](https://registry.terraform.io/browse/providers) o exemplo de criação de vários providers.

Para declarar um providder AWS criamos o arquivo [/terraform-project-base/provider.tf](/terraform-project-base/provider.tf) com o conteúdo capturado da documentação (https://registry.terraform.io/providers/hashicorp/aws/latest/docs#example-usage):
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

Vamos criar um bucket S3, será declarado no arquivo [terraform-project-base/s3.tf](/terraform-project-base/s3.tf).
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
[terraform.tfstate](/terraform-project-base/terraform.tfstate) é um arquivo que mantém o estado, o versionamento do que foi criado anteriormente no provedor e informações sensíveis. Após o “apply” os arquivos terraform.tfstate e terraform.tfstate.backup sãqo criados, este último com informações sensíveis.
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

No arquivo terraform-project-base/provider.tf editamos para acessar a regiao de São Paulo. Como essa região é paga, aqui foca o código de exemplo, porém vamos continuar utilizando us-east-1:
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
O recurso do terraform precisa ter um label único. Variables representam entrada de dados (de fora do módulo). Não deveria depender de nada interno, porque o valor pode vir de `tfvars`, `CLI` (-var), ou até de outro módulo.

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

## Datasource
Data Source busca informações de recursos existentes na AWS (não cria novos recursos), acessa recursos que não foram criados pelo terraform para que possamos capturar informações desses recursos e utilizá-las.

Por exemplo, pode-se buscar AMI mais recente ([terraform.io/data-sources/ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)), pois é um valor mutável:

Veja https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance.

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

No arquivo `.tf` podemos utilizar o valor do id do AMI, por exemplo: `data.aws_ami.amazon_linux.id` em [terraform-project-base/ec2.tf](/terraform-project-base/ec2.tf).
O `$ terraform plan` exibe os atributos que podemos extrair do dado.
Precisamos fornecer informações simples, que possamos lembrar, e únicas para que possamos filtrar um recurso específico do provider e nõa uma lista.

Poderemos verificar em AWS > EC2 > Instances a instancia criada.
![EC2 criada com terraform](/assets/ec2-terraform.png)

No exemplo utilizamos o nome de um bucket previamente criado fora do terraform para criar um novo bucket.
![Buckets criados com terraform](/assets/buckets-terraform.png)

## Locals
Dados definidos em arquivos locais do terraform, diferente das variáveis que podem ser definidas em um arquivo `.tf`, por um arquivo `terraform.tfvars` ou até mesmo por linha de comando. Documentation https://developer.hashicorp.com/terraform/language/block/locals.
Sãos dados bons para utilizar valores fixos.

Vamos destruir a EC2 criada com `$ terraaform apply -destroy -target="aws_instance.web"` para recriarmos ela utilizando valores locais.

```json
locals {
    name = "fiap"
    school = "postech"
}
# utilização
"${local.name}"
```

Não é possível usar local dentro de um bloco `variable`, mas é comum interpolar/ acessar variables em locals.
Local realiza a construção de valores derivados. Pode usar variables, pode concatenar strings, pode aplicar funções, etc.

## Module
[Module](https://developer.hashicorp.com/terraform/language/modules) é um recurso que permite encapsular e reutilizar configurações de recursos do terraform. Ele é útil pra ser reutilizável e se quisermos, alterar poucos parâmetros apenas.

Podemos encontrar diversos módulos em https://registry.terraform.io/browse/modules.

Exemplo de modulo de [EC2 instance](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest) e exemplo de utilização em repositório de código https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/tree/master/examples/complete. 
Para criarmos um módulo utilizando essa estrutura basta utilizar o trecho em "Provision Instructions", também é possível visualizar resources, inputs e[outputs](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest#outputs) pro exemplo.

Para executar e realizar os downloads do módulo:
```bash
~/terraform-modules$ terraform init
terraform plan
terrafom apply
```

Para utilizar o módulo em outro projeto, basta criar um arquivo `main.tf` e utilizar o módulo:
```json
module "ec2-instance" {
  source = "./terraform-modules"
}
```

### Criando módulo

Para utilizar um módulo local, criamos um arquivo `main.tf` apontando o local de declaração do módulo.
Exemplo em [terraform-project-modules/main.tf](./terraform-project-modules/main.tf), substituindo as propriedades sem valor declarado no módulo.

```json
module "ec2" {
  source = "../modules/ec2"

  ami = data.aws_ami.ubuntu.id
  instance_name = var.instance_name
}

module "s3" {
    source = "../modules/s3"
    bucket_name = "fiap-modules-terraform"
}
```
Assim, para criar um EC2 ou um bucket S3, podemos apenas utilizar esses módulos e passar as variáveis, tornando bem mais prático e reutilizável.

Precisamos executar `terraform init -reconfigure`, e `apply`

![EC2 criado com módulos](/assets/ec2-s3-modules.png)

## Loops

No Terraform não existe “for” ou “while” como em linguagens de programação, mas temos duas construções muito usadas para iterar sobre listas ou mapas.
Utilizamos no arquivo [/terraform-project-base/ec2.tf](/terraform-project-base/ec2.tf).

### 1. count

Cria N cópias de um recurso. Bom para repetição simples.
Exemplo: criar 3 buckets S3 de uma vez, onde `count.index` vai de 0 até N-1.
```json
resource "aws_s3_bucket" "buckets" {
  count  = 3
  bucket = "meu-bucket-${count.index}"
}
```
Aqui ele criaria meu-bucket-0, meu-bucket-1, meu-bucket-2. 
![](/assets/loop-count-ec2.png)

### 2. for_each

Mais poderoso: permite iterar sobre listas ou mapas.
Assim você pode usar uma chave para identificar cada recurso.

Exemplo com lista:
```json
resource "aws_s3_bucket" "buckets" {
  for_each = toset(["dev", "staging", "prod"])
  bucket = "meu-bucket-${each.key}"
}
```

Vai criar três buckets: meu-bucket-dev, meu-bucket-staging, meu-bucket-prod. Onde `each.key` é a chave (quando itera set/map) e `each.value` o valor (quando itera lista/mapa).
Quando usamos `set` o each.value é igual ao each.key.

Para definir chave e valor com valores diferentes podemos usar o for_each com um mapa:
```json
for_each = {
  dev     = "kamila"
  staging = "joao"
  prod    = "maria"
}
```
 - each.key → "dev", "staging", "prod", each.value → "kamila", "joao", "maria"


### 3. for expression (listas/mapas dentro de locals)

Além de count e for_each, você pode criar listas/mapas derivados com expressões for.
Por exemplo (mapa):
```
locals {
  buckets = ["dev", "staging", "prod"]
  buckets_tags = { for b in local.buckets : b => "owner-${b}" }
}
```

Resultado:
```
{
  dev     = "owner-dev"
  staging = "owner-staging"
  prod    = "owner-prod"
}
```
Podemos usar as expressões regulares

### Expressões regex

### Regexall
O regexall(pattern, string) aplica uma expressão regular a uma string e retorna uma lista com todas as correspondências.
Exemplod e uso em [terraform-project-base/ec2.tf](/terraform-project-base/ec2.tf).

```hcl
output "regex_bucket" {
  value = regexall("kamila-lab-\\d+", var.bucket_name_list)
}
// Resultado
[
  "kamila-lab-2025",
  "kamila-lab-2026",
  "kamila-lab-2027",
  "kamila-lab-2019",
]
```
Usando na criação de recursos:

```
# Variável com lista de buckets separados por vírgula
variable "bucket_name_list" {
  default = "kamila-lab-2025,kamila-lab-2026,kamila-lab-2027,kamila-lab-2019"
}

# Locals: extrai os nomes dos buckets usando regex e transforma em set
locals {
  bucket_names = toset(flatten(regexall("kamila-lab-\\d+", var.bucket_name_list)))
}

# Criação de buckets S3 usando for_each
resource "aws_s3_bucket" "buckets" {
  for_each = local.bucket_names

  bucket = each.key
  tags = {
    Name = each.key
  }
}

# Criação de instâncias EC2 usando os mesmos nomes
resource "aws_instance" "ec2_for_bucket" {
  for_each = local.bucket_names

  ami           = "ami-12345678"  # Substitua por AMI válida
  instance_type = "t2.micro"

  tags = {
    Name = "ec2-${each.key}"
  }
}
```

É possível verificar com outputs, `terraform output` ou `terraform output bucket_names`.
<details>
  <summary>Outputs para verificar os recursos criados com regex</summary>

```json
# Outputs para verificação
output "bucket_names" {
  value = local.bucket_names
}

output "s3_buckets" {
  value = [for b in aws_s3_bucket.buckets : b.bucket]
}

output "ec2_instances" {
  value = [for i in aws_instance.ec2_for_bucket : i.tags["Name"]]
}
```
</details>


