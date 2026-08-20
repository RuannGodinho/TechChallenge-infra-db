# TechChallenge-infra-db

Terraform do **banco gerenciado** para o Tech Challenge. A aplicação continua usando MongoDB in-cluster até você ligar `enable_managed_db`.

## Escolha: Atlas M0 (custo ~US$ 0)

| Opção | Custo lab | Compatível com Mongoose | Observação |
|---|---|---|---|
| **MongoDB Atlas M0** (este repo) | Gratuito | Sim | Melhor custo-benefício; conta Atlas à parte |
| AWS DocumentDB | Dezenas de US$/mês (`db.t3.medium`) | Quase (TLS + limitações) | Só vale se a rubrica exigir 100% AWS |
| Mongo no EKS (hoje) | Só EBS | Sim | Não é banco gerenciado |

Não há stack DocumentDB neste repositório de propósito: o M0 cobre o requisito de IaC + banco gerenciado sem queimar crédito.

## O que é criado (`enable_managed_db = true`)

- Projeto + cluster Atlas **M0** (TENANT / AWS `US_EAST_1`)
- Database user `readWrite` no DB `Node-Fiap`
- IP access list (default `0.0.0.0/0` — só laboratório)
- SSM SecureString `/techchallenge/db/mongodb_uri`

Default **`enable_managed_db = false`**: `plan`/`apply` não criam Atlas.

## CI/CD

| Workflow | Gatilho | Efeito |
|---|---|---|
| CI | push/PR | `fmt` + `validate` |
| Terraform | manual | plan/apply/destroy (`confirm=yes`) |

### Secrets quando for ligar o Atlas

- `MONGODB_ATLAS_PUBLIC_KEY`
- `MONGODB_ATLAS_PRIVATE_KEY`
- `MONGODB_ATLAS_ORG_ID`
- `MONGODB_ATLAS_DB_PASSWORD`
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (SSM)
- `TF_STATE_BUCKET` — mesmo bucket do EKS
- Variable `ENABLE_MANAGED_DB=true`

## Cutover da API

1. Apply deste repo com `enable_managed_db=true`.
2. No [TechChallenge-Fiap](https://github.com/RuannGodinho/TechChallenge-Fiap), apontar `k8s/secrets/Api-configmap.yml` (`MONGODB_URI`) para o valor do SSM.
3. Parar de aplicar `k8s/mongo/` no CD.
4. `docker-compose` local **não muda**.
