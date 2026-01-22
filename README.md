# Infraestrutura Kubernetes – Tech Challenge

Este repositório é responsável pelo **provisionamento da infraestrutura de
Kubernetes na nuvem**, incluindo rede, cluster Kubernetes (EKS) e recursos
necessários para execução da aplicação do Tech Challenge.

Toda a infraestrutura é provisionada utilizando **Terraform**, com execução
automatizada via **Terraform Cloud**, seguindo práticas de Infraestrutura como
Código (IaC).

---

## 🎯 Objetivo do Repositório

O objetivo deste repositório é:

- Criar a **base de infraestrutura** para execução da aplicação
- Provisionar rede (VPC, subnets e segurança)
- Criar o **cluster Kubernetes**
- Disponibilizar outputs para outros repositórios
- Servir como **dependência de rede** para o banco de dados e aplicação

Este repositório **não contém código de aplicação**, apenas infraestrutura.

---

## 🧱 Arquitetura Provisionada

Este repositório provisiona os seguintes componentes:

- VPC dedicada
- Subnets públicas
- Regras de roteamento e acesso à internet
- Cluster Kubernetes (Amazon EKS)
- Node Group (nós de trabalho)
- Repositório de imagens (ECR)
- Outputs para integração com outros repositórios

A aplicação e o banco de dados utilizam **outputs deste repositório** para
conectividade de rede.

---

## 🧰 Tecnologias Utilizadas

- **Terraform**
- **Terraform Cloud**
- **Amazon Web Services (AWS)**
- **Amazon EKS**
- **Amazon EC2**
- **Amazon ECR**
- **GitHub**

---

## 🔗 Dependências e Integrações

Este repositório é a **base de infraestrutura para os demais componentes do
projeto**, sendo responsável pelo provisionamento de rede e do cluster
Kubernetes.

### Repositórios Relacionados

- **Aplicação Principal (Kubernetes)**  
  https://github.com/CarlosENdS/fiap-techchallenge-cargarage

- **Infraestrutura do Banco de Dados (RDS)**  
  https://github.com/CarlosENdS/fiap-techchallenge-infra-database

- **Autenticação Serverless (Lambda)**  
  https://github.com/Leonardo-almd/lambda-cargarage-auth

> ⚠️ **Importante**  
> O repositório `infra-database` depende diretamente das **VPCs e subnets
> provisionadas neste repositório**, consumindo esses dados por meio de
> `terraform_remote_state`.

---

## 🚀 Deploy com Terraform Cloud

O provisionamento da infraestrutura é realizado utilizando **Terraform Cloud**,
com integração direta ao GitHub, seguindo o modelo de Infraestrutura como Código
(IaC).

### Premissas

- Workspace previamente criado no Terraform Cloud
- Repositório conectado ao workspace
- Execução remota habilitada
- Diretório de trabalho configurado como `terraform/`

### Fluxo de Deploy

1. Após o merge na branch principal (main)
2. O Terraform Cloud executa automaticamente o **terraform plan** e em seguida o **terraform apply** é executado
4. A infraestrutura é criada ou atualizada na AWS

---

## 🔐 Gerenciamento de Variáveis e Roles

As variáveis de configuração e credenciais são definidas diretamente no
**Terraform Cloud**, garantindo segurança e evitando versionamento de dados
sensíveis.

### Variáveis configuradas no Terraform Cloud

- Região da AWS
- Nome do projeto
- Ambiente (`dev`, `homolog`, `prod`)
- Configurações do cluster Kubernetes

## 🔐 Configuração Manual das IAM Roles (AWS Academy)

Devido às **limitações do ambiente AWS Academy**, as **IAM Roles necessárias para
o funcionamento do Amazon EKS não são criadas automaticamente pelo Terraform**
neste projeto.

Essas roles devem ser **criadas manualmente** e seus **ARNs informados como
variáveis** no Terraform Cloud.

---

### IAM Role do Cluster EKS

Esta role é utilizada pelo **plano de controle do EKS**.

#### Configurações necessárias

- **Trusted Entity**:  
  `eks.amazonaws.com`

- **Policies obrigatórias**:
  - `AmazonEKSClusterPolicy`
  - `AmazonEKSServicePolicy`

Essa role deve ser informada no Terraform como a role do cluster EKS.

---

### IAM Role do Node Group (Worker Nodes)

Esta role é utilizada pelas **instâncias EC2 que executam os pods**.

#### Configurações necessárias

- **Trusted Entity**:  
  `ec2.amazonaws.com`

- **Policies obrigatórias**:
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEC2ContainerRegistryReadOnly`
  - `AmazonEKS_CNI_Policy`

Essa role deve ser informada no Terraform como a role dos Node Groups.

---

### Variáveis no Terraform Cloud

Após a criação manual das roles, os seguintes valores devem ser configurados
como **variáveis no Terraform Cloud**:

- ARN da IAM Role do cluster EKS
- ARN da IAM Role do Node Group

Essas variáveis permitem que o Terraform utilize as roles existentes sem tentar
criá-las automaticamente.

---

### Observações Importantes

- Nenhuma IAM Role é versionada no repositório
- Essa abordagem garante compatibilidade com **AWS Academy** e contas AWS padrão
- Em um ambiente de produção sem essas limitações, as roles poderiam ser
  provisionadas diretamente via Terraform


---

## 📤 Outputs

Este repositório expõe outputs utilizados por outros componentes da arquitetura,
incluindo:

- ID da VPC
- IDs das subnets
- Endpoint do cluster Kubernetes
- Nome do cluster
- URL do repositório ECR

Esses outputs são consumidos por:

- Infraestrutura do banco de dados
- Pipeline da aplicação
- Configurações de deploy Kubernetes

---

## 📚 Documentação Arquitetural

As decisões arquiteturais relacionadas a este repositório estão documentadas em
**ADRs**, disponíveis no diretório `/docs`.

Entre os tópicos documentados estão:
- Uso do Kubernetes (EKS)
- Estratégia de rede
- Uso de Node Groups
- Uso do Terraform Cloud
- Limitações do ambiente AWS Academy

