#!/bin/bash

# DevOps Portfolio - Quick Setup Script
# This script automates the initial deployment to minikube

set -e  # Exit on error

echo "========================================="
echo "DevOps Portfolio - Quick Setup"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."

command -v docker >/dev/null 2>&1 || { print_error "Docker is not installed. Please install Docker first."; exit 1; }
print_success "Docker is installed"

command -v kubectl >/dev/null 2>&1 || { print_error "kubectl is not installed. Please install kubectl first."; exit 1; }
print_success "kubectl is installed"

command -v minikube >/dev/null 2>&1 || { print_error "minikube is not installed. Please install minikube first."; exit 1; }
print_success "minikube is installed"

echo ""

# Start minikube
echo "Starting minikube cluster..."
if minikube status | grep -q "Running"; then
    print_info "Minikube is already running"
else
    minikube start --cpus=4 --memory=8192 --disk-size=20g
    print_success "Minikube started successfully"
fi

echo ""

# Build Docker images
echo "Building Docker images..."
eval $(minikube docker-env)

print_info "Building User Service..."
docker build -t devops-demo/user-service:latest ./user-service

print_info "Building Product Service..."
docker build -t devops-demo/product-service:latest ./product-service

print_info "Building API Gateway..."
docker build -t devops-demo/api-gateway:latest ./api-gateway

print_success "All Docker images built successfully"

echo ""

# Update Kubernetes manifests with local images
echo "Updating Kubernetes manifests..."
sed -i.bak 's|your-dockerhub-username/user-service:latest|devops-demo/user-service:latest|g' k8s/user-service-deployment.yaml
sed -i.bak 's|your-dockerhub-username/product-service:latest|devops-demo/product-service:latest|g' k8s/product-service-deployment.yaml
sed -i.bak 's|your-dockerhub-username/api-gateway:latest|devops-demo/api-gateway:latest|g' k8s/api-gateway-deployment.yaml
print_success "Manifests updated"

echo ""

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."

kubectl apply -f k8s/namespace.yaml
print_success "Namespace created"

kubectl apply -f k8s/
print_success "All resources deployed"

echo ""

# Wait for deployments
echo "Waiting for deployments to be ready..."

kubectl wait --for=condition=available --timeout=300s \
  deployment/user-service -n devops-demo 2>/dev/null && \
  print_success "User Service is ready" || \
  print_error "User Service failed to start"

kubectl wait --for=condition=available --timeout=300s \
  deployment/product-service -n devops-demo 2>/dev/null && \
  print_success "Product Service is ready" || \
  print_error "Product Service failed to start"

kubectl wait --for=condition=available --timeout=300s \
  deployment/api-gateway -n devops-demo 2>/dev/null && \
  print_success "API Gateway is ready" || \
  print_error "API Gateway failed to start"

kubectl wait --for=condition=available --timeout=300s \
  deployment/prometheus -n devops-demo 2>/dev/null && \
  print_success "Prometheus is ready" || \
  print_error "Prometheus failed to start"

kubectl wait --for=condition=available --timeout=300s \
  deployment/grafana -n devops-demo 2>/dev/null && \
  print_success "Grafana is ready" || \
  print_error "Grafana failed to start"

echo ""

# Get service URLs
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""

MINIKUBE_IP=$(minikube ip)

echo "Service URLs:"
echo "  API Gateway:  http://${MINIKUBE_IP}:30080"
echo "  Prometheus:   http://${MINIKUBE_IP}:30090"
echo "  Grafana:      http://${MINIKUBE_IP}:30030 (admin/admin)"
echo ""

echo "Quick Test Commands:"
echo "  # Health check"
echo "  curl http://${MINIKUBE_IP}:30080/health"
echo ""
echo "  # Create a user"
echo "  curl -X POST http://${MINIKUBE_IP}:30080/api/users \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"name\":\"John Doe\",\"email\":\"john@example.com\"}'"
echo ""
echo "  # Get all users"
echo "  curl http://${MINIKUBE_IP}:30080/api/users"
echo ""

echo "Monitoring:"
echo "  kubectl get pods -n devops-demo"
echo "  kubectl logs -f deployment/api-gateway -n devops-demo"
echo ""

echo "To access services via browser:"
echo "  minikube service api-gateway -n devops-demo"
echo "  minikube service prometheus -n devops-demo"
echo "  minikube service grafana -n devops-demo"
echo ""

print_success "Setup complete! Your DevOps portfolio is ready."
