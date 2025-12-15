# Operations Runbook

## Quick Reference

| Service | Port | Health Check | Metrics |
|---------|------|--------------|---------|
| API Gateway | 3000 (30080) | `/health` | `/metrics` |
| User Service | 8081 | `/api/users/health` | `/actuator/prometheus` |
| Product Service | 8082 | `/api/products/health` | `/actuator/prometheus` |
| Prometheus | 9090 (30090) | `/-/healthy` | N/A |
| Grafana | 3000 (30030) | `/api/health` | N/A |

## Deployment Procedures

### Initial Deployment

#### Prerequisites Check
```bash
# Verify tools are installed
docker --version
kubectl version --client
minikube version
terraform --version

# Check system resources
free -h  # At least 8GB RAM recommended
df -h    # At least 20GB disk space
```

#### Deploy to Minikube

```bash
# 1. Start minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --disk-size=20g

# 2. Verify cluster is running
kubectl cluster-info
kubectl get nodes

# 3. Build Docker images (if not using pre-built)
eval $(minikube docker-env)  # Use minikube's Docker daemon
docker-compose build

# 4. Deploy application
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# 5. Wait for deployments to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/user-service -n devops-demo
kubectl wait --for=condition=available --timeout=300s \
  deployment/product-service -n devops-demo
kubectl wait --for=condition=available --timeout=300s \
  deployment/api-gateway -n devops-demo

# 6. Verify all pods are running
kubectl get pods -n devops-demo

# 7. Get service URLs
minikube service list -n devops-demo
```

### Rolling Update

```bash
# Update image tag in deployment
kubectl set image deployment/user-service \
  user-service=vit112/user-service:v2.0 \
  -n devops-demo

# Monitor rollout
kubectl rollout status deployment/user-service -n devops-demo

# Verify new version
kubectl describe deployment user-service -n devops-demo | grep Image
```

### Rollback

```bash
# View rollout history
kubectl rollout history deployment/user-service -n devops-demo

# Rollback to previous version
kubectl rollout undo deployment/user-service -n devops-demo

# Rollback to specific revision
kubectl rollout undo deployment/user-service --to-revision=2 -n devops-demo

# Verify rollback
kubectl rollout status deployment/user-service -n devops-demo
```

### Scaling

```bash
# Scale up
kubectl scale deployment/user-service --replicas=5 -n devops-demo

# Scale down
kubectl scale deployment/user-service --replicas=2 -n devops-demo

# Verify scaling
kubectl get deployment user-service -n devops-demo
kubectl get pods -n devops-demo -l app=user-service
```

## Monitoring

### Accessing Dashboards

```bash
# Prometheus
kubectl port-forward -n devops-demo svc/prometheus 9090:9090
# Visit http://localhost:9090

# Grafana
kubectl port-forward -n devops-demo svc/grafana 3000:3000
# Visit http://localhost:3000 (admin/admin)

# Or use minikube service
minikube service prometheus -n devops-demo
minikube service grafana -n devops-demo
```

### Key Metrics to Monitor

#### Service Health
```promql
# All services up
up{job="kubernetes-pods"}

# Service availability percentage
avg_over_time(up{job="kubernetes-pods"}[5m]) * 100
```

#### Request Metrics
```promql
# Request rate (requests per second)
rate(http_server_requests_seconds_count[5m])

# Error rate
rate(http_server_requests_seconds_count{status=~"5.."}[5m])

# Request latency P95
histogram_quantile(0.95, 
  rate(http_server_requests_seconds_bucket[5m]))
```

#### Resource Usage
```promql
# CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Memory usage
container_memory_usage_bytes / container_spec_memory_limit_bytes * 100

# Pod restarts
rate(kube_pod_container_status_restarts_total[15m])
```

### Setting Up Alerts

```bash
# Apply alert rules
kubectl apply -f k8s/monitoring/prometheus-alerts.yaml

# Verify alerts are loaded
kubectl port-forward -n devops-demo svc/prometheus 9090:9090
# Visit http://localhost:9090/alerts
```

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl get pods -n devops-demo

# Describe pod for events
kubectl describe pod <pod-name> -n devops-demo

# Check logs
kubectl logs <pod-name> -n devops-demo

# Check previous logs (if pod restarted)
kubectl logs <pod-name> -n devops-demo --previous

# Common issues:
# - ImagePullBackOff: Check image name and registry credentials
# - CrashLoopBackOff: Check application logs
# - Pending: Check resource availability (CPU/memory)
```

### Service Not Accessible

```bash
# Check service endpoints
kubectl get svc -n devops-demo
kubectl get endpoints -n devops-demo

# Verify pod labels match service selector
kubectl get pods -n devops-demo --show-labels
kubectl describe svc user-service -n devops-demo

# Test service from within cluster
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
# Inside pod:
wget -O- http://user-service.devops-demo:8081/api/users/health
```

### High Memory Usage

```bash
# Check current usage
kubectl top pods -n devops-demo

# Increase memory limits
kubectl set resources deployment/user-service \
  --limits=memory=2Gi \
  -n devops-demo

# Check for memory leaks in logs
kubectl logs <pod-name> -n devops-demo | grep -i "memory\|heap\|oom"
```

### Database Connection Issues

```bash
# Check H2 console (if enabled)
kubectl port-forward <pod-name> 8081:8081 -n devops-demo
# Visit http://localhost:8081/h2-console

# Check application properties
kubectl exec <pod-name> -n devops-demo -- \
  cat /app/application.yml

# Restart pod to reset in-memory database
kubectl delete pod <pod-name> -n devops-demo
```

### Prometheus Not Scraping

```bash
# Check Prometheus targets
kubectl port-forward -n devops-demo svc/prometheus 9090:9090
# Visit http://localhost:9090/targets

# Verify pod annotations
kubectl get pods -n devops-demo -o yaml | grep -A 3 annotations

# Check Prometheus logs
kubectl logs -n devops-demo -l app=prometheus

# Verify RBAC permissions
kubectl auth can-i list pods --as=system:serviceaccount:devops-demo:prometheus
```

### CI/CD Pipeline Failures

#### Test Failures
```bash
# Run tests locally
cd user-service
mvn clean test

# Check test reports
cat target/surefire-reports/*.xml
```

#### Docker Build Failures
```bash
# Build locally to debug
docker build -t user-service:debug ./user-service

# Check build logs
docker build --no-cache -t user-service:debug ./user-service
```

#### Deployment Failures
```bash
# Check GitHub Actions logs
# Go to repository → Actions → Select failed workflow

# Verify secrets are set
# Settings → Secrets and variables → Actions

# Test kubectl access
echo $KUBECONFIG | base64 -d > /tmp/kubeconfig
kubectl --kubeconfig=/tmp/kubeconfig get pods -n devops-demo
```

## Backup and Recovery

### Backup Kubernetes Resources

```bash
# Backup all resources
kubectl get all -n devops-demo -o yaml > backup-$(date +%Y%m%d).yaml

# Backup specific resources
kubectl get deployment,service,configmap -n devops-demo -o yaml > backup.yaml

# Backup with kustomize
kubectl kustomize k8s/ > backup-kustomize.yaml
```

### Restore from Backup

```bash
# Delete namespace (caution!)
kubectl delete namespace devops-demo

# Restore from backup
kubectl apply -f backup-20241213.yaml

# Verify restoration
kubectl get all -n devops-demo
```

### Disaster Recovery

```bash
# 1. Verify backup exists
ls -lh backup-*.yaml

# 2. Create new cluster (if needed)
minikube delete
minikube start --cpus=4 --memory=8192

# 3. Restore application
kubectl apply -f backup-latest.yaml

# 4. Verify services
kubectl get pods -n devops-demo
kubectl get svc -n devops-demo

# 5. Test endpoints
curl http://$(minikube ip):30080/health
```

## Performance Tuning

### JVM Tuning (Java Services)

```yaml
# Add to deployment env
env:
- name: JAVA_OPTS
  value: "-Xms512m -Xmx1024m -XX:+UseG1GC"
```

### Node.js Tuning (API Gateway)

```yaml
# Add to deployment env
env:
- name: NODE_OPTIONS
  value: "--max-old-space-size=512"
```

### Resource Optimization

```bash
# Check actual resource usage
kubectl top pods -n devops-demo

# Adjust requests/limits based on actual usage
kubectl set resources deployment/user-service \
  --requests=cpu=100m,memory=256Mi \
  --limits=cpu=500m,memory=512Mi \
  -n devops-demo
```

## Security Operations

### Rotate Secrets

```bash
# Create new secret
kubectl create secret generic db-credentials \
  --from-literal=username=newuser \
  --from-literal=password=newpass \
  -n devops-demo \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart deployments to pick up new secret
kubectl rollout restart deployment/user-service -n devops-demo
```

### Update Docker Registry Credentials

```bash
# Create new image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  -n devops-demo
```

### Security Scanning

```bash
# Scan Docker images with Trivy
trivy image vit112/user-service:latest

# Check for vulnerabilities
docker scan vit112/user-service:latest
```

## Maintenance Windows

### Planned Maintenance Procedure

```bash
# 1. Notify users (if applicable)
# 2. Scale down to 1 replica
kubectl scale deployment --all --replicas=1 -n devops-demo

# 3. Perform maintenance
# - Update configurations
# - Apply patches
# - Upgrade dependencies

# 4. Scale back up
kubectl scale deployment --all --replicas=2 -n devops-demo

# 5. Verify health
kubectl get pods -n devops-demo
curl http://$(minikube ip):30080/health
```

### Cluster Upgrade

```bash
# 1. Backup current state
kubectl get all -n devops-demo -o yaml > pre-upgrade-backup.yaml

# 2. Upgrade minikube
minikube stop
minikube delete
minikube start --kubernetes-version=v1.28.0

# 3. Restore applications
kubectl apply -f pre-upgrade-backup.yaml

# 4. Verify
kubectl version
kubectl get pods -n devops-demo
```

## Logging

### View Logs

```bash
# Tail logs for a pod
kubectl logs -f <pod-name> -n devops-demo

# View logs from all pods of a deployment
kubectl logs -f deployment/user-service -n devops-demo

# View logs from previous container instance
kubectl logs <pod-name> -n devops-demo --previous

# Export logs to file
kubectl logs <pod-name> -n devops-demo > pod-logs.txt
```

### Centralized Logging (Future)

```bash
# Install ELK stack
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch -n logging
helm install kibana elastic/kibana -n logging
helm install filebeat elastic/filebeat -n logging
```

## Contact and Escalation

### On-Call Rotation
- Primary: [Name] - [Contact]
- Secondary: [Name] - [Contact]
- Manager: [Name] - [Contact]

### Escalation Path
1. **Level 1**: On-call engineer (15 min response)
2. **Level 2**: Senior engineer (30 min response)
3. **Level 3**: Engineering manager (1 hour response)

### Communication Channels
- Slack: #devops-alerts
- Email: devops-team@company.com
- PagerDuty: [Integration key]

---

**Last Updated**: December 2024  
**Maintained by**: DevOps Team
