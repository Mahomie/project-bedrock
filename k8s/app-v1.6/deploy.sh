#!/bin/bash
# Project Bedrock - Retail Store Sample App v1.6.1 deployment
# Per-service Helm charts with managed AWS data layer (RDS/DynamoDB)
set -e
NS=retail-app
VERSION=1.6.1
REGISTRY=oci://public.ecr.aws/aws-containers

# Pre-create DB secrets from AWS Secrets Manager (credentials never hardcoded)
MYSQL_USER=$(aws secretsmanager get-secret-value --secret-id project-bedrock-cluster/mysql/credentials --query SecretString --output text | python3 -c "import sys,json;print(json.load(sys.stdin)['username'])")
MYSQL_PASS=$(aws secretsmanager get-secret-value --secret-id project-bedrock-cluster/mysql/credentials --query SecretString --output text | python3 -c "import sys,json;print(json.load(sys.stdin)['password'])")
PG_USER=$(aws secretsmanager get-secret-value --secret-id project-bedrock-cluster/postgres/credentials --query SecretString --output text | python3 -c "import sys,json;print(json.load(sys.stdin)['username'])")
PG_PASS=$(aws secretsmanager get-secret-value --secret-id project-bedrock-cluster/postgres/credentials --query SecretString --output text | python3 -c "import sys,json;print(json.load(sys.stdin)['password'])")

kubectl create secret generic catalog-db-1-6 -n $NS \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USER="$MYSQL_USER" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_PASSWORD="$MYSQL_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic orders-db-1-6 -n $NS \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_USERNAME="$PG_USER" \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_PASSWORD="$PG_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy each service
helm upgrade --install catalog  $REGISTRY/retail-store-sample-catalog-chart  --version $VERSION -n $NS -f catalog-values.yaml --wait
helm upgrade --install orders   $REGISTRY/retail-store-sample-orders-chart   --version $VERSION -n $NS -f orders-values.yaml --wait
helm upgrade --install carts    $REGISTRY/retail-store-sample-cart-chart     --version $VERSION -n $NS -f cart-values.yaml --wait
helm upgrade --install checkout $REGISTRY/retail-store-sample-checkout-chart --version $VERSION -n $NS -f checkout-values.yaml --wait
helm upgrade --install ui       $REGISTRY/retail-store-sample-ui-chart       --version $VERSION -n $NS -f ui-values.yaml --wait

kubectl apply -f ../ingress/ingress.yaml
echo "Deployment complete."
