# DevOps Portfolio - Architecture Documentation

## System Overview

This document provides a detailed technical overview of the DevOps Portfolio microservices architecture, design decisions, and operational considerations.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         External Traffic                             │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │   Kubernetes Ingress   │
                    │   (NodePort: 30080)    │
                    └────────────┬───────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │     API Gateway        │
                    │   (Node.js/Express)    │
                    │   Replicas: 2          │
                    │   Port: 3000           │
                    └────┬──────────────┬────┘
                         │              │
            ┌────────────┘              └────────────┐
            ▼                                        ▼
┌───────────────────────┐              ┌───────────────────────┐
│   User Service        │              │  Product Service      │
│   (Spring Boot)       │              │  (Spring Boot)        │
│   Replicas: 2         │              │  Replicas: 2          │
│   Port: 8081          │              │  Port: 8082           │
│   Database: H2 (mem)  │              │  Database: H2 (mem)   │
└───────────┬───────────┘              └───────────┬───────────┘
            │                                      │
            └──────────────┬───────────────────────┘
                           │
                           │ Metrics Scraping
                           ▼
                ┌──────────────────────┐
                │    Prometheus        │
                │    Port: 9090        │
                │  (NodePort: 30090)   │
                └──────────┬───────────┘
                           │
                           │ Data Source
                           ▼
                ┌──────────────────────┐
                │      Grafana         │
                │      Port: 3000      │
                │  (NodePort: 30030)   │
                └──────────────────────┘
```

## Component Details

### 1. API Gateway (Node.js/Express)

**Responsibilities:**
- Request routing to backend services
- Service aggregation
- Load balancing
- Metrics collection
- Error handling and circuit breaking

**Technology Stack:**
- Node.js 20
- Express.js 4.x
- Axios for HTTP requests
- prom-client for Prometheus metrics

**Key Features:**
- Health check endpoint (`/health`)
- Prometheus metrics endpoint (`/metrics`)
- Request/response logging
- CORS support
- Security headers (Helmet)
- Timeout handling (5s default)

**Scaling Considerations:**
- Stateless design enables horizontal scaling
- Connection pooling for backend services
- Async/await for non-blocking I/O

### 2. User Service (Spring Boot)

**Responsibilities:**
- User management (CRUD operations)
- User authentication (future)
- User data persistence

**Technology Stack:**
- Java 17
- Spring Boot 3.2
- Spring Data JPA
- H2 Database (in-memory)
- Micrometer for metrics

**API Endpoints:**
- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `GET /api/users/health` - Health check

**Data Model:**
```java
User {
  Long id;
  String name;
  String email;
  LocalDateTime createdAt;
}
```

### 3. Product Service (Spring Boot)

**Responsibilities:**
- Product catalog management
- Inventory tracking
- Product search

**Technology Stack:**
- Java 17
- Spring Boot 3.2
- Spring Data JPA
- H2 Database (in-memory)
- Micrometer for metrics

**API Endpoints:**
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `GET /api/products/search?name={name}` - Search products
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product
- `GET /api/products/health` - Health check

**Data Model:**
```java
Product {
  Long id;
  String name;
  String description;
  BigDecimal price;
  Integer stock;
  LocalDateTime createdAt;
}
```

## Design Decisions

### 1. Microservices Architecture

**Why Microservices?**
- **Independent Scaling**: Each service can scale based on its own load
- **Technology Diversity**: Mix Java and Node.js to demonstrate polyglot architecture
- **Fault Isolation**: Failure in one service doesn't bring down the entire system
- **Team Autonomy**: Different teams can own different services

**Trade-offs:**
- Increased operational complexity
- Network latency between services
- Distributed data management challenges

### 2. In-Memory Databases

**Why H2?**
- Simplifies deployment (no external database required)
- Fast startup and testing
- Sufficient for demonstration purposes

**Production Considerations:**
- Replace with PostgreSQL/MySQL for persistence
- Implement database per service pattern
- Add connection pooling and monitoring

### 3. Containerization Strategy

**Multi-Stage Builds:**
```dockerfile
# Build stage - includes build tools
FROM maven:3.9-eclipse-temurin-17 AS build
# ... build application

# Runtime stage - minimal image
FROM eclipse-temurin:17-jre-alpine
# ... copy artifacts only
```

**Benefits:**
- Smaller final images (JRE vs JDK)
- Faster deployment
- Reduced attack surface
- Layer caching for faster builds

### 4. Kubernetes Deployment

**Resource Management:**
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

**Health Checks:**
- **Liveness Probe**: Restart pod if unhealthy
- **Readiness Probe**: Remove from service if not ready
- **Startup Probe**: Allow slow-starting apps time to initialize

**Replica Strategy:**
- 2 replicas per service for high availability
- Supports rolling updates with zero downtime
- Ready for horizontal pod autoscaling (HPA)

## Observability Strategy

### Metrics Collection

**Three-Tier Approach:**

1. **Application Metrics** (Custom)
   - Business metrics (users created, products sold)
   - Application-specific counters and gauges

2. **Framework Metrics** (Spring Actuator, prom-client)
   - HTTP request rates and latencies
   - JVM metrics (heap, threads, GC)
   - Node.js event loop metrics

3. **Infrastructure Metrics** (Kubernetes)
   - Pod CPU and memory usage
   - Container restart counts
   - Network I/O

### Prometheus Architecture

**Scrape Configuration:**
- Service discovery via Kubernetes annotations
- 15-second scrape interval
- Automatic target discovery

**Alerting Rules:**
- Service down alerts (critical)
- High error rate (warning)
- Resource exhaustion (warning)
- Pod restart frequency (warning)

### Grafana Dashboards

**Recommended Panels:**
- Request rate (requests/second)
- Error rate (percentage)
- Request duration (P50, P95, P99)
- Service uptime
- Resource utilization

## CI/CD Pipeline Architecture

### Pipeline Stages

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Code   │───▶│  Test   │───▶│  Build  │───▶│ Deploy  │
│ Commit  │    │         │    │  Image  │    │   K8s   │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              │              │
     │              │              │              │
     ▼              ▼              ▼              ▼
  GitHub      Maven/npm      Docker Hub     kubectl set
  Actions       Test          Push           image
```

### Deployment Strategy

**Rolling Update:**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

**Benefits:**
- Zero downtime deployments
- Gradual rollout
- Easy rollback
- Health check validation

### GitOps Workflow

1. Developer pushes code to GitHub
2. GitHub Actions triggers on push
3. Tests run automatically
4. Docker image built and tagged
5. Image pushed to registry
6. Kubernetes deployment updated
7. Rolling update performed
8. Health checks validate deployment

## Security Considerations

### Container Security

- **Non-root user**: Run containers as non-root (future enhancement)
- **Minimal base images**: Alpine Linux for smaller attack surface
- **No secrets in images**: Use Kubernetes secrets
- **Image scanning**: Integrate Trivy/Snyk in CI/CD

### Kubernetes Security

- **RBAC**: Role-based access control for Prometheus
- **Network Policies**: Restrict pod-to-pod communication (future)
- **Pod Security Standards**: Enforce security contexts
- **Secrets Management**: Use Kubernetes secrets, not ConfigMaps

### Application Security

- **Input Validation**: Validate all user inputs
- **SQL Injection Prevention**: Use JPA prepared statements
- **CORS Configuration**: Restrict allowed origins
- **Rate Limiting**: Implement in API Gateway (future)

## Scalability Considerations

### Horizontal Scaling

**Current State:**
- Manual replica configuration
- Fixed 2 replicas per service

**Future Enhancements:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: user-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: user-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Database Scaling

**Current Limitations:**
- In-memory H2 doesn't persist data
- No replication or clustering

**Production Approach:**
- Migrate to PostgreSQL/MySQL
- Implement read replicas
- Use connection pooling
- Consider caching layer (Redis)

### Caching Strategy

**Recommended Additions:**
- Redis for session storage
- CDN for static assets
- Application-level caching (Spring Cache)
- HTTP caching headers

## Disaster Recovery

### Backup Strategy

**Application State:**
- Database backups (when using persistent DB)
- Configuration backups (Git)
- Secrets backup (encrypted)

**Recovery Time Objective (RTO):**
- Target: < 15 minutes
- Achieved via automated deployments

**Recovery Point Objective (RPO):**
- Target: < 5 minutes
- Achieved via database replication

### High Availability

**Current Setup:**
- 2 replicas per service
- Kubernetes self-healing
- Health check-based recovery

**Production Enhancements:**
- Multi-zone deployment
- External load balancer
- Database clustering
- Backup region (DR site)

## Performance Optimization

### Current Optimizations

1. **Docker Layer Caching**: Faster builds
2. **Maven Dependency Caching**: Faster CI/CD
3. **Multi-Stage Builds**: Smaller images
4. **Connection Pooling**: Efficient resource usage

### Future Optimizations

1. **Database Indexing**: Faster queries
2. **Query Optimization**: Reduce N+1 queries
3. **Async Processing**: Background jobs
4. **CDN Integration**: Static asset delivery
5. **Compression**: Gzip/Brotli responses

## Monitoring and Alerting

### Alert Severity Levels

| Level | Response Time | Examples |
|-------|---------------|----------|
| **Critical** | Immediate | Service down, data loss |
| **Warning** | 30 minutes | High error rate, resource usage |
| **Info** | Next business day | Deployment events, scaling |

### On-Call Runbook

1. **Alert Received**: Check Grafana dashboards
2. **Investigate**: Review logs and metrics
3. **Mitigate**: Scale up, restart, or rollback
4. **Resolve**: Fix root cause
5. **Document**: Update runbook

## Technology Choices Rationale

| Technology | Why Chosen | Alternatives Considered |
|------------|------------|------------------------|
| **Spring Boot** | Industry standard, rich ecosystem | Quarkus, Micronaut |
| **Node.js** | Async I/O for gateway, lightweight | Go, Python |
| **Kubernetes** | Industry standard, cloud-agnostic | Docker Swarm, ECS |
| **Prometheus** | Pull-based, Kubernetes-native | Datadog, New Relic |
| **Grafana** | Open source, powerful visualization | Kibana, Datadog |
| **GitHub Actions** | Integrated with GitHub, free tier | Jenkins, GitLab CI |
| **Terraform** | Declarative IaC, multi-cloud | Pulumi, CloudFormation |

## Future Enhancements

### Short Term (1-3 months)
- [ ] Add API authentication (JWT)
- [ ] Implement rate limiting
- [ ] Add request tracing (Jaeger)
- [ ] Database persistence (PostgreSQL)
- [ ] Horizontal Pod Autoscaling

### Medium Term (3-6 months)
- [ ] Service mesh (Istio/Linkerd)
- [ ] Distributed tracing
- [ ] Centralized logging (ELK stack)
- [ ] API documentation (Swagger)
- [ ] Load testing (k6/Gatling)

### Long Term (6-12 months)
- [ ] Multi-region deployment
- [ ] Event-driven architecture (Kafka)
- [ ] Advanced chaos engineering
- [ ] Cost optimization
- [ ] ML-based anomaly detection

## References

- [12-Factor App Methodology](https://12factor.net/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Spring Boot Production Best Practices](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Google SRE Book](https://sre.google/books/)

---

**Last Updated**: December 2024  
**Version**: 1.0.0
