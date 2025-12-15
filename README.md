# DevOps Portfolio: CI/CD & Observability Playground

A production-grade microservices application demonstrating DevOps and SRE best practices including automated CI/CD, infrastructure-as-code, comprehensive monitoring, and chaos engineering.

[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Visualization-Grafana-F46800?logo=grafana&logoColor=white)](https://grafana.com/)

## 🎯 Project Overview

This project showcases a complete DevOps ecosystem with:

- **3 Microservices**: User Service (Java/Spring Boot), Product Service (Java/Spring Boot), API Gateway (Node.js/Express)
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Kubernetes with health checks, resource limits, and auto-scaling capabilities
- **Infrastructure as Code**: Terraform for reproducible deployments
- **CI/CD Pipeline**: GitHub Actions with automated testing, building, and deployment
- **Observability**: Prometheus for metrics collection, Grafana for visualization, custom dashboards
- **Chaos Engineering**: Resilience testing with Chaos Mesh

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway (Node.js)                   │
│                    Port: 3000 (NodePort: 30080)             │
└────────────┬────────────────────────────┬───────────────────┘
             │                            │
             ▼                            ▼
    ┌────────────────┐          ┌────────────────┐
    │  User Service  │          │Product Service │
    │  (Spring Boot) │          │  (Spring Boot) │
    │  Port: 8081    │          │  Port: 8082    │
    └────────┬───────┘          └────────┬───────┘
             │                            │
             └──────────┬─────────────────┘
                        │
                        ▼
              ┌──────────────────┐
              │   Prometheus     │
              │   Port: 9090     │
              │ (NodePort: 30090)│
              └─────────┬────────┘
                        │
                        ▼
              ┌──────────────────┐
              │     Grafana      │
              │   Port: 3000     │
              │ (NodePort: 30030)│
              └──────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Docker** (v20.10+)
- **Kubernetes** (minikube, k3s, or cloud provider)
- **kubectl** (v1.27+)
- **Terraform** (v1.0+) - optional
- **Maven** (v3.8+) - for local development
- **Node.js** (v20+) - for local development

### Local Development with Docker Compose

```bash
# Clone the repository
git clone <your-repo-url>
cd DevOps

# Start all services
docker-compose up -d

# Check service health
docker-compose ps

# View logs
docker-compose logs -f

# Access services
# API Gateway: http://localhost:3000
# User Service: http://localhost:8081
# Product Service: http://localhost:8082
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin)

# Stop services
docker-compose down
```

### Kubernetes Deployment

#### Option 1: Using kubectl

```bash
# Start minikube
minikube start --cpus=4 --memory=8192

# Create namespace and deploy all services
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=user-service -n devops-demo --timeout=300s
kubectl wait --for=condition=ready pod -l app=product-service -n devops-demo --timeout=300s
kubectl wait --for=condition=ready pod -l app=api-gateway -n devops-demo --timeout=300s

# Check deployment status
kubectl get pods -n devops-demo
kubectl get svc -n devops-demo

# Access services
minikube service api-gateway -n devops-demo
minikube service prometheus -n devops-demo
minikube service grafana -n devops-demo
```

#### Option 2: Using Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply configuration
terraform apply

# View outputs
terraform output
```

## 📊 Monitoring & Observability

### Prometheus Metrics

Each service exposes Prometheus metrics:

- **User Service**: `http://localhost:8081/actuator/prometheus`
- **Product Service**: `http://localhost:8082/actuator/prometheus`
- **API Gateway**: `http://localhost:3000/metrics`

### Custom Metrics

- `users_created_total` - Total number of users created
- `products_created_total` - Total number of products created
- `gateway_http_requests_total` - Total HTTP requests through gateway
- `gateway_http_request_duration_seconds` - Request duration histogram

### Grafana Dashboards

Access Grafana at `http://localhost:30030` (Kubernetes) or `http://localhost:3001` (Docker Compose)

**Default credentials**: admin/admin

Pre-configured dashboards show:
- Request rates and latencies
- Error rates
- Resource utilization (CPU, memory)
- Service health status

## 🧪 Testing the Application

### API Examples

```bash
# Get minikube IP (for Kubernetes)
MINIKUBE_IP=$(minikube ip)
GATEWAY_URL="http://${MINIKUBE_IP}:30080"

# Or for Docker Compose
GATEWAY_URL="http://localhost:3000"

# Create a user
curl -X POST ${GATEWAY_URL}/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'

# Get all users
curl ${GATEWAY_URL}/api/users

# Create a product
curl -X POST ${GATEWAY_URL}/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"High-performance laptop","price":999.99,"stock":10}'

# Get all products
curl ${GATEWAY_URL}/api/products

# Get user dashboard (aggregated endpoint)
curl ${GATEWAY_URL}/api/users/1/dashboard
```

### Running Tests Locally

```bash
# Test User Service
cd user-service
mvn test

# Test Product Service
cd product-service
mvn test

# Test API Gateway
cd api-gateway
npm install
npm test
```

## 🔄 CI/CD Pipeline

The project includes GitHub Actions workflows for each service:

### Pipeline Stages

1. **Test**: Run unit and integration tests
2. **Build**: Build Docker images with multi-stage builds
3. **Push**: Push images to Docker Hub
4. **Deploy**: Update Kubernetes deployments

### Required GitHub Secrets

```
DOCKER_USERNAME - Docker Hub username
DOCKER_PASSWORD - Docker Hub password or access token
KUBECONFIG - Base64-encoded kubeconfig file
```

### Setting up CI/CD

```bash
# Encode your kubeconfig
cat ~/.kube/config | base64

# Add to GitHub Secrets:
# Settings → Secrets and variables → Actions → New repository secret
```

## 🌪️ Chaos Engineering

Test system resilience with chaos experiments:

```bash
# Install Chaos Mesh (if not already installed)
kubectl create ns chaos-mesh
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm install chaos-mesh chaos-mesh/chaos-mesh -n chaos-mesh

# Run pod failure experiment
kubectl apply -f chaos/pod-failure.yaml

# Monitor service behavior in Grafana during chaos

# Stop experiment
kubectl delete -f chaos/pod-failure.yaml

# Run network latency experiment
kubectl apply -f chaos/network-latency.yaml
```

## 📁 Project Structure

```
DevOps/
├── user-service/              # Java/Spring Boot user management service
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── product-service/           # Java/Spring Boot product catalog service
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── api-gateway/               # Node.js/Express API gateway
│   ├── routes/
│   ├── tests/
│   ├── package.json
│   ├── server.js
│   └── Dockerfile
├── k8s/                       # Kubernetes manifests
│   ├── namespace.yaml
│   ├── *-deployment.yaml
│   ├── *-service.yaml
│   └── monitoring/
│       ├── prometheus-*.yaml
│       └── grafana-*.yaml
├── terraform/                 # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── .github/workflows/         # CI/CD pipelines
│   ├── user-service-ci.yml
│   ├── product-service-ci.yml
│   └── api-gateway-ci.yml
├── monitoring/                # Monitoring configuration
│   └── prometheus.yml
├── chaos/                     # Chaos engineering experiments
│   ├── pod-failure.yaml
│   └── network-latency.yaml
├── docker-compose.yml         # Local development environment
└── README.md
```

## 🛠️ Technology Stack

| Component | Technology |
|-----------|-----------|
| **Backend Services** | Java 17, Spring Boot 3.2, Maven |
| **API Gateway** | Node.js 20, Express.js |
| **Containerization** | Docker, Docker Compose |
| **Orchestration** | Kubernetes (minikube/k3s) |
| **Infrastructure as Code** | Terraform |
| **CI/CD** | GitHub Actions |
| **Metrics** | Prometheus, Micrometer |
| **Visualization** | Grafana |
| **Chaos Engineering** | Chaos Mesh |
| **Testing** | JUnit, Jest, Supertest |

## 📈 Key Features

### DevOps Best Practices

✅ **Automated CI/CD** - Full pipeline from code commit to deployment  
✅ **Infrastructure as Code** - Reproducible infrastructure with Terraform  
✅ **Containerization** - Multi-stage Docker builds for optimized images  
✅ **Orchestration** - Kubernetes with health checks and resource management  
✅ **Observability** - Comprehensive metrics and dashboards  
✅ **Chaos Engineering** - Resilience testing and validation  
✅ **GitOps** - Version-controlled infrastructure and configuration  
✅ **Security** - Secrets management, RBAC, network policies  

### Production-Ready Features

- Health check endpoints for all services
- Graceful shutdown handling
- Resource limits and requests
- Horizontal pod autoscaling ready
- Rolling updates with zero downtime
- Prometheus metrics instrumentation
- Structured logging
- Error handling and retry logic

## 🔧 Troubleshooting

### Common Issues

**Pods not starting**
```bash
kubectl describe pod <pod-name> -n devops-demo
kubectl logs <pod-name> -n devops-demo
```

**Service not accessible**
```bash
kubectl get svc -n devops-demo
minikube service list
```

**Prometheus not scraping metrics**
```bash
# Check Prometheus targets
kubectl port-forward -n devops-demo svc/prometheus 9090:9090
# Visit http://localhost:9090/targets
```

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Chaos Engineering Principles](https://principlesofchaos.org/)

## 🤝 Contributing

This is a portfolio project, but suggestions and improvements are welcome!

## 📝 License

MIT License - feel free to use this project as a template for your own DevOps portfolio.

## 👤 Author

**Ishaan Verma**
- GitHub: [@ishaanv18](https://github.com/ishaanv18)
- LinkedIn: [Ishaan Verma](https://www.linkedin.com/in/ishaan-verma-03s/)

---

**Built to showcase production-ready DevOps skills** 🚀
