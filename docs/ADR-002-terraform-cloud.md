# ADR-002 – Uso do Terraform Cloud no Provisionamento

## Status
Aceito

## Data de aceite
2026-01-01

## Contexto
Execuções locais do Terraform podem causar divergência de estado e falta de
padronização entre os membros do grupo.

## Decisão
Utilizar **Terraform Cloud** para execução remota do Terraform.

## Alternativas Consideradas
- **Execução local do Terraform**  
  Rejeitada por risco de inconsistência.
- **Backend remoto com execução local**  
  Rejeitada por ainda depender de execução manual.

## Justificativa
- Estado remoto centralizado
- Integração com GitHub
- Execução automática via Pull Request

## Consequências
- Dependência de workspace configurado
