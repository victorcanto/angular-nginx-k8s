#!/bin/bash

# Função para checar se um comando existe
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Verificar se Minikube está instalado
if ! command_exists minikube; then
  echo "Minikube não está instalado. Instalando Minikube..."
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
fi

# Verificar se kubectl está instalado
if ! command_exists kubectl; then
  echo "kubectl não está instalado. Instalando kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# Iniciar Minikube
echo "Iniciando Minikube..."
minikube start

# Utilizar o Docker do Minikube
eval $(minikube docker-env)

# Construir a imagem Docker
echo "Construindo a imagem Docker..."
docker build -t angular-ssr-nginx:1.0.0 .

# Aplicar os manifests do Kubernetes
echo "Aplicando os manifests do Kubernetes..."
kubectl apply -f ./k8s/deployment.yaml
kubectl apply -f ./k8s/service.yaml

# Obter IP do Minikube e porta atribuída pelo NodePort
minikube_ip=$(minikube ip)
node_port=$(kubectl get service angular-ssr-service -o=jsonpath='{.spec.ports[0].nodePort}')

echo "A aplicação está disponível em http://$minikube_ip:$node_port"

# Aguardar até que o pod esteja pronto
while true; do
  ready=$(kubectl get pods -l app=angular-ssr -o jsonpath='{.items[0].status.containerStatuses[0].ready}')
  if [ "$ready" = "true" ]; then
    break
  else
    sleep 1
  fi
done

echo "Se estiver usando o Docker Desktop, a aplicação está disponível em:"
# Executar comando para obter a URL do serviço
minikube service angular-ssr-service --url
