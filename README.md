# TechChallenge-infra-db

Persistência da **Node-Fiap**. O Mongo de laboratório **sobe no EKS** (Deployment + Service ClusterIP + PVC), com manifests e CD **neste** repositório. A API no [TechChallenge-Fiap](https://github.com/RuannGodinho/TechChallenge-Fiap) só consome `mongodb://mongo-service:27017/Node-Fiap`.

Atlas M0 continua opt-in via Terraform (`enable_managed_db=true`) se quiser banco gerenciado no lugar do pod.

## O que este repo sobe no cluster

| Recurso | Manifest | Função |
|---|---|---|
| StorageClass `gp2` | `k8s/mongo-storageclass.yml` | EBS CSI (só se ainda não existir) |
| PVC `mongo-pvc` | `k8s/mongo-pvc.yml` | 1 Gi persistente |
| Service `mongo-service` | `k8s/mongo-service.yml` | ClusterIP `:27017` |
| Deployment `mongo-deployment` | `k8s/mongo-deployment.yml` | MongoDB 8 |

O CD também grava `/techchallenge/db/mongodb_uri` = `mongodb://mongo-service:27017/Node-Fiap`.

## CI/CD

| Workflow | Gatilho | Efeito |
|---|---|---|
| CI | push/PR | Terraform `fmt` + `validate` |
| CD | `workflow_dispatch` (`confirm=yes`) | `kubectl apply` do Mongo no EKS |
| Terraform | `workflow_dispatch` | Atlas M0 opt-in (`enable_managed_db`) |

Secrets do CD Kubernetes: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`. Variables: `TF_AWS_REGION`, `TF_CLUSTER_NAME` (`techchallenge-eks`).

Pré-requisito: cluster do [TechChallenge-infra-eks](https://github.com/RuannGodinho/TechChallenge-infra-eks).

```bash
aws eks update-kubeconfig --region us-east-1 --name techchallenge-eks
kubectl get storageclass gp2 || kubectl apply -f k8s/mongo-storageclass.yml
kubectl apply -f k8s/mongo-pvc.yml
kubectl apply -f k8s/mongo-service.yml
kubectl apply -f k8s/mongo-deployment.yml
kubectl rollout status deployment/mongo-deployment --timeout=180s
```

## Atlas (opt-in)

Terraform cria projeto + cluster M0 e publica outra URI no mesmo SSM. Default `enable_managed_db = false`. Secrets: `MONGODB_ATLAS_*`, `TF_STATE_BUCKET`.

## Documentação

RFC-002 / ADR-002: [docs/](docs/README.md). ER: [modelo de dados no Fiap](https://github.com/RuannGodinho/TechChallenge-Fiap/blob/main/docs/ARQUITETURA-MODELO-DADOS.md).
