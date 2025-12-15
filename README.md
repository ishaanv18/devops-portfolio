# DevOps Portfolio: Production-Ready Microservices Platform

[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Visualization-Grafana-F46800?logo=grafana&logoColor=white)](https://grafana.com/)

> **A comprehensive DevOps portfolio demonstrating production-grade practices in microservices architecture, container orchestration, CI/CD automation, infrastructure as code, and observability.**

---

## 📖 Table of Contents

- [Project Purpose](#-project-purpose)
- [What This Project Showcases](#-what-this-project-showcases)
- [Problems Solved](#-problems-solved)
- [Architecture Deep Dive](#-architecture-deep-dive)
- [Technology Stack](#-technology-stack)
- [Quick Start](#-quick-start)
- [Detailed Setup](#-detailed-setup)
- [Monitoring & Observability](#-monitoring--observability)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Chaos Engineering](#-chaos-engineering)
- [Author](#-author)

---

## 🎯 Project Purpose

This project serves as a **comprehensive demonstration of modern DevOps and Site Reliability Engineering (SRE) practices**. It's designed to showcase the complete lifecycle of building, deploying, monitoring, and maintaining a production-ready microservices application.

### Why This Project Exists

In today's cloud-native landscape, organizations need engineers who can:
- Design and implement scalable microservices architectures
- Automate deployment pipelines for continuous delivery
- Implement comprehensive monitoring and observability
- Manage infrastructure as code for reproducibility
- Ensure system reliability through chaos engineering
- Apply security best practices throughout the stack

This portfolio demonstrates **hands-on proficiency** in all these areas through a fully functional, production-ready application.

### Real-World Application

This project simulates a real-world e-commerce platform backend with:
- **User Management Service**: Handles user registration, authentication, and profile management
- **Product Catalog Service**: Manages product inventory, pricing, and availability
- **API Gateway**: Provides unified entry point, request routing, and aggregation

While simplified for demonstration purposes, the architecture and practices mirror those used in production systems at scale.

---

## 🌟 What This Project Showcases

### 1. **Microservices Architecture**
- **Service Decomposition**: Breaking down a monolithic application into independent, loosely-coupled services
- **Polyglot Development**: Using Java/Spring Boot for business services and Node.js/Express for the API Gateway
- **Service Communication**: RESTful APIs with proper error handling and retry logic
- **Data Isolation**: Each service manages its own database (H2 in-memory for demo)

### 2. **Containerization & Orchestration**
- **Docker Multi-Stage Builds**: Optimized images with separate build and runtime stages
- **Container Best Practices**: Non-root users, minimal base images (Alpine), health checks
- **Kubernetes Deployment**: Production-ready manifests with proper resource limits, health probes, and scaling capabilities
- **Service Discovery**: Kubernetes DNS-based service discovery
- **Load Balancing**: Built-in Kubernetes service load balancing

### 3. **CI/CD Automation**
- **Automated Testing**: Unit tests run on every commit
- **Continuous Integration**: Automated builds triggered by code changes
- **Continuous Deployment**: Automatic deployment to Kubernetes on successful builds
- **Image Management**: Automated Docker image building, tagging, and pushing to Docker Hub
- **GitOps Workflow**: Infrastructure and application configuration managed through Git

### 4. **Infrastructure as Code (IaC)**
- **Terraform Modules**: Reproducible infrastructure provisioning
- **Declarative Configuration**: Kubernetes manifests for all resources
- **Version Control**: All infrastructure code tracked in Git
- **Environment Parity**: Same configuration across dev, staging, and production

### 5. **Observability & Monitoring**
- **Metrics Collection**: Prometheus scraping application and system metrics
- **Visualization**: Grafana dashboards for real-time monitoring
- **Custom Metrics**: Application-specific business metrics (users created, products sold, etc.)
- **Health Checks**: Liveness and readiness probes for all services
- **Distributed Tracing Ready**: Architecture supports adding tools like Jaeger

### 6. **Reliability Engineering**
- **Chaos Engineering**: Resilience testing with Chaos Mesh
- **Graceful Degradation**: Services handle failures without cascading
- **Resource Management**: Proper CPU and memory limits prevent resource exhaustion
- **Rolling Updates**: Zero-downtime deployments
- **Rollback Capability**: Quick rollback to previous versions

### 7. **Security Best Practices**
- **Secrets Management**: Kubernetes secrets for sensitive data
- **Network Policies**: Service-to-service communication control (ready to implement)
- **RBAC**: Role-based access control for Kubernetes resources
- **Container Security**: Minimal attack surface with Alpine images
- **Dependency Scanning**: Automated vulnerability scanning in CI/CD

---

## 🔧 Problems Solved

### Traditional Deployment Challenges

**Problem**: Manual deployment processes are error-prone, slow, and don't scale.  
**Solution**: Fully automated CI/CD pipeline with GitHub Actions that builds, tests, and deploys on every commit to main branch.

**Problem**: Inconsistent environments between development, testing, and production.  
**Solution**: Docker containers ensure identical runtime environments. Infrastructure as Code (Terraform) guarantees reproducible infrastructure.

**Problem**: Difficulty tracking application health and performance in production.  
**Solution**: Comprehensive observability stack with Prometheus metrics, Grafana dashboards, and health check endpoints.

### Microservices Complexity

**Problem**: Managing multiple services with different tech stacks is complex.  
**Solution**: Standardized containerization, unified monitoring, and centralized API gateway for request routing.

**Problem**: Service failures can cascade and bring down entire systems.  
**Solution**: Chaos engineering experiments validate resilience. Health checks and proper resource limits prevent cascading failures.

**Problem**: Scaling monolithic applications is inefficient.  
**Solution**: Microservices architecture allows independent scaling of services based on demand.

### Operational Overhead

**Problem**: Manual infrastructure provisioning is time-consuming and error-prone.  
**Solution**: Terraform automates infrastructure provisioning with declarative configuration.

**Problem**: Lack of visibility into system behavior makes troubleshooting difficult.  
**Solution**: Prometheus metrics, Grafana dashboards, and structured logging provide deep insights.

**Problem**: Ensuring system reliability requires constant manual testing.  
**Solution**: Automated chaos experiments validate system resilience continuously.

---

## 🏗️ Architecture Deep Dive

```
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway (Node.js)                   │
│                    Port: 3000 (NodePort: 30080)             │
│  - Request Routing      - Load Balancing                    │
│  - Response Aggregation - Metrics Collection                │
└────────────┬────────────────────────────┬───────────────────┘
             │                            │
             ▼                            ▼
    ┌────────────────┐          ┌────────────────┐
    │  User Service  │          │Product Service │
    │  (Spring Boot) │          │  (Spring Boot) │
    │  Port: 8081    │          │  Port: 8082    │
    │  - REST API    │          │  - REST API    │
    │  - H2 Database │          │  - H2 Database │
    │  - Actuator    │          │  - Actuator    │
    └────────┬───────┘          └────────┬───────┘
             │                            │
             └──────────┬─────────────────┘
                        │ (Metrics Scraping)
                        ▼
              ┌──────────────────┐
              │   Prometheus     │
              │   Port: 9090     │
              │ (NodePort: 30090)│
              │  - Metrics Store │
              │  - Alerting      │
              └─────────┬────────┘
                        │
                        ▼
              ┌──────────────────┐
              │     Grafana      │
              │   Port: 3000     │
              │ (NodePort: 30030)│
              │  - Dashboards    │
              │  - Visualization │
              └──────────────────┘
```

### Component Details

#### API Gateway (Node.js/Express)
**Purpose**: Single entry point for all client requests, providing routing, aggregation, and cross-cutting concerns.

**Responsibilities**:
- **Request Routing**: Forwards requests to appropriate microservices
- **Response Aggregation**: Combines data from multiple services (e.g., user dashboard endpoint)
- **Load Balancing**: Distributes traffic across service instances
- **Metrics Collection**: Exposes Prometheus metrics for monitoring
- **Error Handling**: Provides consistent error responses

**Technology**: Node.js 20 with Express.js framework

#### User Service (Java/Spring Boot)
**Purpose**: Manages user-related operations including registration, authentication, and profile management.

**Endpoints**:
- `POST /api/users` - Create new user
- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `GET /api/users/health` - Health check

**Technology**: Java 17, Spring Boot 3.2, Spring Data JPA, H2 Database

#### Product Service (Java/Spring Boot)
**Purpose**: Manages product catalog including inventory, pricing, and availability.

**Endpoints**:
- `POST /api/products` - Create new product
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product
- `GET /api/products/health` - Health check

**Technology**: Java 17, Spring Boot 3.2, Spring Data JPA, H2 Database

#### Prometheus
**Purpose**: Time-series database for metrics collection and alerting.

**Features**:
- Scrapes metrics from all services every 15 seconds
- Stores metrics for querying and analysis
- Supports PromQL for complex queries
- Provides alerting capabilities (configured but not active in demo)

#### Grafana
**Purpose**: Visualization and dashboarding platform for metrics.

**Features**:
- Real-time dashboards for service health
- Pre-configured Prometheus data source
- Customizable panels for different metrics
- Alert visualization and management

### Data Flow

1. **Client Request** → API Gateway receives HTTP request
2. **Routing** → Gateway routes to appropriate service (User/Product)
3. **Processing** → Service processes request, interacts with database
4. **Response** → Service returns data to Gateway
5. **Aggregation** (if needed) → Gateway combines responses from multiple services
6. **Client Response** → Gateway returns final response to client

### Deployment Architecture

**Local Development (Docker Compose)**:
- All services run as Docker containers
- Services communicate via Docker network
- Ports exposed on localhost for testing

**Production (Kubernetes)**:
- Each service deployed as a Deployment with 2 replicas
- Services exposed via ClusterIP for internal communication
- API Gateway exposed via NodePort for external access
- Monitoring stack in same namespace
- Resource limits and health checks configured

---

## 🛠️ Technology Stack

### Backend Services
| Technology | Version | Purpose |
|------------|---------|---------|
| **Java** | 17 | Primary language for business services |
| **Spring Boot** | 3.2.0 | Framework for building microservices |
| **Spring Data JPA** | 3.2.0 | Database access and ORM |
| **H2 Database** | Runtime | In-memory database for demo |
| **Lombok** | Latest | Reduce boilerplate code |
| **Maven** | 3.8+ | Build tool and dependency management |

### API Gateway
| Technology | Version | Purpose |
|------------|---------|---------|
| **Node.js** | 20 | JavaScript runtime |
| **Express.js** | 4.18+ | Web framework |
| **Axios** | 1.6+ | HTTP client for service calls |
| **prom-client** | 15.1+ | Prometheus metrics |
| **Helmet** | 7.1+ | Security headers |
| **Morgan** | 1.10+ | HTTP request logging |

### Containerization & Orchestration
| Technology | Version | Purpose |
|------------|---------|---------|
| **Docker** | 20.10+ | Container runtime |
| **Docker Compose** | 3.8 | Local multi-container orchestration |
| **Kubernetes** | 1.27+ | Production container orchestration |
| **kubectl** | 1.27+ | Kubernetes CLI |
| **Minikube** | Latest | Local Kubernetes cluster |

### CI/CD & Automation
| Technology | Version | Purpose |
|------------|---------|---------|
| **GitHub Actions** | Latest | CI/CD pipeline automation |
| **Docker Hub** | Latest | Container registry |
| **Terraform** | 1.0+ | Infrastructure as Code |

### Monitoring & Observability
| Technology | Version | Purpose |
|------------|---------|---------|
| **Prometheus** | Latest | Metrics collection and storage |
| **Grafana** | Latest | Metrics visualization |
| **Micrometer** | Latest | Application metrics instrumentation |
| **Spring Boot Actuator** | 3.2.0 | Health checks and metrics endpoints |

### Chaos Engineering
| Technology | Version | Purpose |
|------------|---------|---------|
| **Chaos Mesh** | Latest | Kubernetes-native chaos engineering |

### Development Tools
| Technology | Version | Purpose |
|------------|---------|---------|
| **Git** | 2.0+ | Version control |
| **VS Code** | Latest | IDE (recommended) |
| **Postman** | Latest | API testing (optional) |

---

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
