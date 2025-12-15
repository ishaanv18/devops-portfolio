# DevOps Portfolio - Quick Setup Script (Windows PowerShell)
# This script automates the initial deployment to minikube

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "DevOps Portfolio - Quick Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor White

try {
    docker --version | Out-Null
    Print-Success "Docker is installed"
} catch {
    Print-Error "Docker is not installed. Please install Docker Desktop first."
    exit 1
}

try {
    kubectl version --client | Out-Null
    Print-Success "kubectl is installed"
} catch {
    Print-Error "kubectl is not installed. Please install kubectl first."
    exit 1
}

try {
    minikube version | Out-Null
    Print-Success "minikube is installed"
} catch {
    Print-Error "minikube is not installed. Please install minikube first."
    exit 1
}

Write-Host ""

# Start minikube
Write-Host "Starting minikube cluster..." -ForegroundColor White
$minikubeStatus = minikube status 2>&1 | Out-String
if ($minikubeStatus -match "Running") {
    Print-Info "Minikube is already running"
} else {
    minikube start --cpus=4 --memory=8192 --disk-size=20g
    Print-Success "Minikube started successfully"
}

Write-Host ""

# Build Docker images
Write-Host "Building Docker images..." -ForegroundColor White

# Set minikube docker environment
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

Print-Info "Building User Service..."
docker build -t devops-demo/user-service:latest ./user-service

Print-Info "Building Product Service..."
docker build -t devops-demo/product-service:latest ./product-service

Print-Info "Building API Gateway..."
docker build -t devops-demo/api-gateway:latest ./api-gateway

Print-Success "All Docker images built successfully"

Write-Host ""

# Update Kubernetes manifests with local images
Write-Host "Updating Kubernetes manifests..." -ForegroundColor White

$files = @(
    "k8s/user-service-deployment.yaml",
    "k8s/product-service-deployment.yaml",
    "k8s/api-gateway-deployment.yaml"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    $content = $content -replace 'your-dockerhub-username/user-service:latest', 'devops-demo/user-service:latest'
    $content = $content -replace 'your-dockerhub-username/product-service:latest', 'devops-demo/product-service:latest'
    $content = $content -replace 'your-dockerhub-username/api-gateway:latest', 'devops-demo/api-gateway:latest'
    $content | Set-Content $file
}

Print-Success "Manifests updated"

Write-Host ""

# Deploy to Kubernetes
Write-Host "Deploying to Kubernetes..." -ForegroundColor White

kubectl apply -f k8s/namespace.yaml
Print-Success "Namespace created"

kubectl apply -f k8s/
Print-Success "All resources deployed"

Write-Host ""

# Wait for deployments
Write-Host "Waiting for deployments to be ready..." -ForegroundColor White

try {
    kubectl wait --for=condition=available --timeout=300s deployment/user-service -n devops-demo 2>$null
    Print-Success "User Service is ready"
} catch {
    Print-Error "User Service failed to start"
}

try {
    kubectl wait --for=condition=available --timeout=300s deployment/product-service -n devops-demo 2>$null
    Print-Success "Product Service is ready"
} catch {
    Print-Error "Product Service failed to start"
}

try {
    kubectl wait --for=condition=available --timeout=300s deployment/api-gateway -n devops-demo 2>$null
    Print-Success "API Gateway is ready"
} catch {
    Print-Error "API Gateway failed to start"
}

try {
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n devops-demo 2>$null
    Print-Success "Prometheus is ready"
} catch {
    Print-Error "Prometheus failed to start"
}

try {
    kubectl wait --for=condition=available --timeout=300s deployment/grafana -n devops-demo 2>$null
    Print-Success "Grafana is ready"
} catch {
    Print-Error "Grafana failed to start"
}

Write-Host ""

# Get service URLs
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$MINIKUBE_IP = minikube ip

Write-Host "Service URLs:" -ForegroundColor White
Write-Host "  API Gateway:  http://${MINIKUBE_IP}:30080" -ForegroundColor Yellow
Write-Host "  Prometheus:   http://${MINIKUBE_IP}:30090" -ForegroundColor Yellow
Write-Host "  Grafana:      http://${MINIKUBE_IP}:30030 (admin/admin)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Quick Test Commands:" -ForegroundColor White
Write-Host "  # Health check" -ForegroundColor Gray
Write-Host "  curl http://${MINIKUBE_IP}:30080/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "  # Create a user" -ForegroundColor Gray
Write-Host "  curl -X POST http://${MINIKUBE_IP}:30080/api/users ``" -ForegroundColor Cyan
Write-Host "    -H 'Content-Type: application/json' ``" -ForegroundColor Cyan
Write-Host "    -d '{`"name`":`"John Doe`",`"email`":`"john@example.com`"}'" -ForegroundColor Cyan
Write-Host ""
Write-Host "  # Get all users" -ForegroundColor Gray
Write-Host "  curl http://${MINIKUBE_IP}:30080/api/users" -ForegroundColor Cyan
Write-Host ""

Write-Host "Monitoring:" -ForegroundColor White
Write-Host "  kubectl get pods -n devops-demo" -ForegroundColor Cyan
Write-Host "  kubectl logs -f deployment/api-gateway -n devops-demo" -ForegroundColor Cyan
Write-Host ""

Write-Host "To access services via browser:" -ForegroundColor White
Write-Host "  minikube service api-gateway -n devops-demo" -ForegroundColor Cyan
Write-Host "  minikube service prometheus -n devops-demo" -ForegroundColor Cyan
Write-Host "  minikube service grafana -n devops-demo" -ForegroundColor Cyan
Write-Host ""

Print-Success "Setup complete! Your DevOps portfolio is ready."
