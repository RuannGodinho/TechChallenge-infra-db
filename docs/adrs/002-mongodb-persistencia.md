# ADR – Persistimos a oficina no MongoDB

**Casa:** engine e Atlas neste repo. ER e coleções: [TechChallenge-Fiap](https://github.com/RuannGodinho/TechChallenge-Fiap/blob/main/docs/ARQUITETURA-MODELO-DADOS.md).

| Campo | Valor |
|---|---|
| **Número** | 002 |
| **Data** | 21/08/2026 |
| **Dono** | Ruann Correa Godinho |
| **Status** | Aceita |
| **RFC de origem** | [RFC-002](../rfcs/002-mongodb-persistencia.md) |

## Contexto

A Ordem de Serviço é um agregado variável: troca de óleo e retífica não compartilham o mesmo formato. O MVP evolui campos com frequência. O laboratório precisa de persistência que sobreviva a restart do pod, sem RDS pago. A API já fala com o banco só via `MONGODB_URI`.

## Decisão

Persistimos o domínio no **MongoDB** (banco `Node-Fiap`), modelando a OS como documento com peças e serviços aninhados. Em laboratório o Mongo roda **in-cluster** (PVC EBS no TechChallenge-Fiap). **Atlas M0** entra somente com `enable_managed_db=true` **neste** repositório. Os casos de uso não conhecem o driver.

## Consequências

Abrimos a OS em uma leitura, sem JOIN, e evoluímos o esquema sem migration bloqueante. O mesmo URI serve Compose, EKS e Atlas. Em contrapartida, a consistência é por documento; o Mongo in-cluster não é alta disponibilidade; Atlas M0 tem teto de recurso.

## Alternativas

Descartamos PostgreSQL e MySQL neste MVP: o ganho relacional não paga RDS nem o custo de schema da OS. Descartamos DynamoDB porque as listagens e o agregado rico exigiriam GSIs cedo demais. Descartamos Atlas no dia 1 para não bloquear o CD. Descartamos arquivo/SQLite por incompatibilidade com HPA.

O ER de referência, os ajustes do modelo relacional e a explicação dos relacionamentos estão em [ARQUITETURA-MODELO-DADOS.md](https://github.com/RuannGodinho/TechChallenge-Fiap/blob/main/docs/ARQUITETURA-MODELO-DADOS.md).
