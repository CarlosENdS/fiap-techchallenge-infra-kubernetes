# Limitações do AWS Academy para EKS

## Contexto

Durante o desenvolvimento da infraestrutura para o Tech Challenge Fase 2, 
encontramos limitações técnicas do AWS Academy que impediram o provisionamento 
completo do cluster EKS.

## Recursos Provisionados com Sucesso ✅

### 1. Networking (VPC)
- VPC 10.0.0.0/16
- 2 Subnets Públicas (10.0.1.0/24, 10.0.2.0/24)
- 2 Subnets Privadas (10.0.10.0/24, 10.0.11.0/24)
- Internet Gateway
- Route Tables configuradas
- Security Groups para EKS, RDS e aplicação

### 2. RDS PostgreSQL 16
- Instância db.t3.micro
- Storage 20GB com auto-scaling até 100GB
- Backup automático (7 dias de retenção)
- Criptografia em repouso
- Subnet Group em subnets privadas

### 3. ECR (Container Registry)
- Repository privado `cargarage-app`
- Lifecycle policies configuradas
- Scan de vulnerabilidades automático
- Imagens versionadas e tagueadas

### 4. EKS Control Plane
- Cluster Kubernetes 1.29
- Control plane gerenciado pela AWS
- Endpoint público e privado habilitados
- Logs de auditoria habilitados
- Security Groups configurados

## Limitação Encontrada ❌

### EKS Node Group

**Erro**: `NodeCreationFailure: Instances failed to join the kubernetes cluster`

**Root Cause**: 
SSM Agent unable to acquire credentials:
unexpected error getting instance profile role credentials

**Análise**:
- IAM Roles existem no AWS Academy (`LabEksNodeRole`)
- EC2 Instances são criadas com sucesso
- **Problema**: AWS Academy não permite criar/anexar Instance Profiles
- Resultado: Instâncias não conseguem assumir IAM Role
- Consequência: Nodes não se juntam ao cluster

## Solução de Contorno Implementada ✅

### 1. Validação Local (Minikube)

Todos os manifestos Kubernetes foram validados localmente:

```bash
# Namespace, ConfigMaps, Secrets
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml

# PostgreSQL (local)
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml

# Aplicação
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml
kubectl apply -f k8s/hpa.yaml

# Validação
kubectl get pods -n cargarage
kubectl get svc -n cargarage
kubectl get hpa -n cargarage
```

**Resultado**: ✅ Todos os recursos criados com sucesso no Minikube

### 2. Arquitetura Terraform Completa

Todos os arquivos Terraform foram criados e validados:

```bash
terraform validate  # ✅ Success
terraform plan      # ✅ 15 recursos mapeados
```

**Arquivos**:
- `providers.tf` - Configuração AWS
- `variables.tf` - Variáveis parametrizadas
- `network.tf` - VPC completa (4 subnets, IGW, RTs)
- `rds.tf` - PostgreSQL 16 gerenciado
- `ecr.tf` - Registry privado com policies
- `eks.tf` - Cluster EKS (control plane + node group)
- `outputs.tf` - Outputs estruturados

## Ambiente de Produção 🚀

Em uma conta AWS completa (não Academy), o deploy seria executado com sucesso:

```bash
# 1. Provisionar infraestrutura
cd infra
terraform init
terraform apply

# 2. Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name cargarage-eks-dev

# 3. Deploy da aplicação
kubectl apply -f k8s/

# 4. Validar
kubectl get pods -n cargarage
kubectl get svc -n cargarage
```

**Recursos que seriam criados**:
- EKS Cluster com 1-2 worker nodes
- Application Load Balancer (via Ingress)
- Auto-scaling de pods (HPA)
- Conexão com RDS PostgreSQL
- Pull de imagens do ECR privado