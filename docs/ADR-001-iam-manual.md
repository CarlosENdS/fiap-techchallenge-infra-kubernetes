# ADR-001 – Criação Manual de IAM Roles

## Status
Aceito

## Data de aceite
2026-01-01

## Contexto
O EKS e os Node Groups dependem de IAM Roles para funcionamento correto.

No ambiente AWS Academy, existem limitações para criação e gerenciamento de IAM
Roles via Terraform.

## Decisão
As **IAM Roles são criadas manualmente** e seus **ARNs são informados como
variáveis** no Terraform Cloud.

## Alternativas Consideradas
- **Criar IAM via Terraform**  
  Rejeitada por limitações do AWS Academy.
- **Não utilizar IAM Roles**  
  Rejeitada por não ser compatível com EKS.

## Justificativa
- Compatibilidade com ambiente educacional
- Evita falhas de permissão
- Mantém o código reutilizável

## Consequências
- Dependência de configuração manual
- Necessidade de documentação clara
