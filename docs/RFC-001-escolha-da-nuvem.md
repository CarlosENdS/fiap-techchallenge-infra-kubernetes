# RFC-001 – Escolha do Provedor de Nuvem

## Status
Aprovado

## Data de aceite
2026-01-01

## Contexto
O Tech Challenge exige a utilização de infraestrutura em nuvem para execução de
Kubernetes, banco de dados gerenciado, funções serverless e pipelines de CI/CD.

Era necessário escolher um provedor de nuvem que permitisse aprendizado prático,
integração entre serviços e execução de infraestrutura como código.

## Proposta
Utilizar a **Amazon Web Services (AWS)** como provedora de nuvem do projeto.

## Justificativa
- Amplo portfólio de serviços gerenciados (EKS, RDS, Lambda, ECR)
- Integração nativa com Terraform
- Documentação extensa e amplamente utilizada no mercado
- Compatibilidade com ambientes educacionais, como o **AWS Academy**
- Facilidade de integração entre os diferentes repositórios do projeto

## Impactos
- A arquitetura passa a depender dos serviços da AWS
- O grupo ganha experiência prática com uma nuvem amplamente adotada
- Algumas decisões técnicas precisam considerar limitações do AWS Academy
