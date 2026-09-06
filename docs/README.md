# Documentação — TechChallenge-infra-db

Este repositório documenta a **persistência gerenciada** (MongoDB Atlas M0, opt-in) e a **escolha do engine**. O modelo de entidades (ER, relacionamentos, ajustes 3NF → documento) vive na API, que é quem persiste o domínio.

Índice da solução: [TechChallenge-Fiap / docs/ARQUITETURA.md](https://github.com/RuannGodinho/TechChallenge-Fiap/blob/main/docs/ARQUITETURA.md).

| Documento | Conteúdo |
|---|---|
| [RFCs](rfcs/README.md) | [RFC-002](rfcs/002-mongodb-persistencia.md) — MongoDB + in-cluster vs Atlas |
| [ADRs](adrs/README.md) | [ADR-002](adrs/002-mongodb-persistencia.md) |
| [Modelo de dados (ER)](https://github.com/RuannGodinho/TechChallenge-Fiap/blob/main/docs/ARQUITETURA-MODELO-DADOS.md) | Justificativa formal, ER relacional, ajustes e relacionamentos — **TechChallenge-Fiap** |

## O que não fica aqui

| Assunto | Repositório |
|---|---|
| Coleções, ER, cardinalidades | [TechChallenge-Fiap — modelo de dados](https://github.com/RuannGodinho/TechChallenge-Fiap/blob/main/docs/ARQUITETURA-MODELO-DADOS.md) |
| Workloads da API | [TechChallenge-Fiap](https://github.com/RuannGodinho/TechChallenge-Fiap) |
| Cluster EKS / Terraform AWS | [TechChallenge-infra-eks](https://github.com/RuannGodinho/TechChallenge-infra-eks/tree/main/docs) |
