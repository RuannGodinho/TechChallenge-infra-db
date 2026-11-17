# TechChallenge-infra-db

Persistência e RabbitMQ compartilhado dos três serviços no EKS existente. Mantém o padrão Deployment + Service ClusterIP + PVC do Mongo original; cluster, aplicações e Gateway ficam nos repositórios irmãos.

| Componente | Deployment / Service | Imagem | Volume |
|---|---|---|---|
| Orders MongoDB | mongo-deployment / mongo-service:27017 | mongo:8 | mongo-pvc, 1Gi gp2 |
| Execution MongoDB | execution-mongo-deployment / execution-mongo-service:27017 | mongo:8 | execution-mongo-pvc, 1Gi gp2 |
| Billing PostgreSQL | postgres-deployment / postgres-service:5432 | postgres:16-alpine | postgres-pvc, 1Gi gp2 |
| RabbitMQ compartilhado | rabbitmq-deployment / rabbitmq-service:5672 | rabbitmq:4-management | rabbitmq-pvc, 1Gi gp2 |

São quatro pods persistentes com uma réplica cada. Os novos workloads copiam requests de 100m CPU/256Mi e limits de 500m/512Mi do Mongo original; dimensionamento real precisa de medição. Não são bancos de alta disponibilidade. Deployments usam Recreate para preservar o padrão de um escritor por PVC RWO; atualizações interrompem brevemente o respectivo componente. Não aplicar HPA nos bancos/broker.

Os nomes e PVC do Mongo original são preservados. Os dois MongoDBs usam replica sets de um membro (orders-rs e execution-rs), necessários para transações. Jobs mongo-init-job e execution-mongo-init-job inicializam o conjunto via hostname estável do Service, sem apagar os dados; recusam identidade de replica set diferente. Os Services Mongo publicam endpoints ainda não prontos para permitir essa inicialização, e a readiness exige primário. Jobs concluídos não são recriados pelo CD.

## CD e secrets

Ordem: infra-eks → este CD → Fiap (instala Metrics Server/New Relic compartilhados) → Execution/Billing → lambda-auth. Execute o workflow CD com confirm=yes.

GitHub Secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, POSTGRES_PASSWORD, RABBITMQ_USER e RABBITMQ_PASSWORD. Variables: TF_AWS_REGION (us-east-1), TF_CLUSTER_NAME (techchallenge-eks), RABBITMQ_VHOST (oficina). O pipeline gera billing-db-secrets e rabbitmq-secrets no namespace default; não publica credenciais no SSM. Para aplicar manualmente, copie k8s/data-secrets.yml.example para k8s/data-secrets.yml, preencha e aplique antes dos Deployments. O arquivo real é ignorado pelo Git.

Billing deve usar DATABASE_URL=postgresql://billing:<senha-codificada>@postgres-service:5432/billing. Os três aplicativos usam o mesmo RABBITMQ_URL=amqp://<usuario-codificado>:<senha-codificada>@rabbitmq-service:5672/oficina. Codifique caracteres especiais na URI; ajuste o vhost em todas as URLs se mudar RABBITMQ_VHOST. Alterar o Secret não rotaciona automaticamente usuários já persistidos de PostgreSQL/RabbitMQ.

O CD aplica o StorageClass gp2 existente somente se ausente; aplica PVCs, Services e Deployments; aguarda os Jobs de inicialização Mongo e os quatro rollouts. O management do RabbitMQ não é exposto por Service. Mailpit continua restrito ao Compose local.

## Aplicação manual equivalente

Depois de configurar os secrets e o contexto do cluster:

```bash
kubectl apply -f k8s/data-secrets.yml
kubectl get storageclass gp2 || kubectl apply -f k8s/mongo-storageclass.yml
for NAME in mongo execution-mongo postgres rabbitmq; do
  kubectl apply -f "k8s/$NAME-pvc.yml"
  kubectl apply -f "k8s/$NAME-service.yml"
  kubectl apply -f "k8s/$NAME-deployment.yml"
done
for NAME in mongo execution-mongo; do
  kubectl apply -f "k8s/$NAME-init-job.yml"
  kubectl wait --for=condition=complete "job/$NAME-init-job" --timeout=180s
done
for NAME in mongo execution-mongo postgres rabbitmq; do
  kubectl rollout status "deployment/$NAME-deployment" --timeout=180s
done
kubectl get pvc
```

Não remover PVCs para corrigir rollout. Inspecionar logs/eventos e o replica set existente antes de qualquer intervenção em dados. O cluster precisa ter EBS CSI funcional e capacidade disponível. A implantação AWS não foi executada nesta alteração.

## SSM publicado pelo CD

| Parâmetro | Valor |
|---|---|
| /techchallenge/db/mongodb_uri | mongodb://mongo-service:27017/Node-Fiap?replicaSet=orders-rs |
| /techchallenge/db/execution_mongodb_uri | mongodb://execution-mongo-service:27017/execution?replicaSet=execution-rs |
| /techchallenge/db/postgres_host | postgres-service |
| /techchallenge/db/rabbitmq_host | rabbitmq-service |

## Atlas opt-in e documentação

O Terraform Atlas existente permanece opt-in (enable_managed_db=false por padrão), com seu próprio workflow/state e MONGODB_ATLAS_* / TF_STATE_BUCKET. Não executá-lo junto ao CD para tentar configurar os bancos in-cluster: ele publica uma URI alternativa no mesmo parâmetro do Orders.

Validação Terraform existente: terraform fmt -check -recursive, terraform init -backend=false e terraform validate. A validação de manifests não equivale a teste de persistência/failover no EKS.

Histórico: [RFC-002](docs/rfcs/002-mongodb-persistencia.md), [ADR-002](docs/adrs/002-mongodb-persistencia.md), [índice](docs/README.md).
