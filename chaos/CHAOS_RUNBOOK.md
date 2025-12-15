# Chaos Engineering Runbook

## Overview

This runbook provides step-by-step instructions for running chaos engineering experiments on the DevOps microservices platform.

## Prerequisites

- Kubernetes cluster running with all services deployed
- Chaos Mesh installed in the cluster
- Access to Grafana for monitoring
- kubectl configured and authenticated

## Installing Chaos Mesh

```bash
# Add Chaos Mesh Helm repository
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update

# Create namespace
kubectl create namespace chaos-mesh

# Install Chaos Mesh
helm install chaos-mesh chaos-mesh/chaos-mesh \
  --namespace chaos-mesh \
  --set chaosDaemon.runtime=containerd \
  --set chaosDaemon.socketPath=/run/containerd/containerd.sock

# Verify installation
kubectl get pods -n chaos-mesh
```

## Experiment 1: Pod Failure

### Purpose
Test system resilience when backend service pods randomly fail.

### Expected Behavior
- Kubernetes should automatically restart failed pods
- API Gateway should handle service unavailability gracefully
- Overall system should remain available due to multiple replicas

### Running the Experiment

```bash
# 1. Open Grafana dashboard to monitor metrics
kubectl port-forward -n devops-demo svc/grafana 3000:3000

# 2. Apply the pod failure experiment
kubectl apply -f chaos/pod-failure.yaml

# 3. Monitor the experiment
kubectl get podchaos -n devops-demo
kubectl describe podchaos pod-failure-experiment -n devops-demo

# 4. Watch pod restarts
kubectl get pods -n devops-demo -w

# 5. Test API availability
MINIKUBE_IP=$(minikube ip)
while true; do
  curl -s http://${MINIKUBE_IP}:30080/health
  sleep 2
done
```

### Metrics to Monitor

- Pod restart count
- API Gateway error rate
- Request latency (should spike during pod failures)
- Service availability percentage

### Cleanup

```bash
kubectl delete -f chaos/pod-failure.yaml
```

## Experiment 2: Network Latency

### Purpose
Test system performance when network latency is introduced to the API Gateway.

### Expected Behavior
- Increased response times
- Potential timeout errors if latency is too high
- Metrics should show degraded performance

### Running the Experiment

```bash
# 1. Establish baseline metrics
# Record current p95 latency from Grafana

# 2. Apply network latency experiment
kubectl apply -f chaos/network-latency.yaml

# 3. Monitor the experiment
kubectl get networkchaos -n devops-demo
kubectl describe networkchaos network-latency-experiment -n devops-demo

# 4. Test API response times
time curl http://$(minikube ip):30080/api/users
time curl http://$(minikube ip):30080/api/products

# 5. Run load test (optional)
for i in {1..100}; do
  curl -s http://$(minikube ip):30080/api/users > /dev/null &
done
wait
```

### Metrics to Monitor

- Request duration histogram
- API Gateway response times
- Timeout errors
- User experience degradation

### Cleanup

```bash
kubectl delete -f chaos/network-latency.yaml
```

## Experiment 3: Custom - High CPU Load

### Purpose
Test autoscaling and performance under high CPU load.

### Creating the Experiment

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  name: cpu-stress-experiment
  namespace: devops-demo
spec:
  mode: one
  selector:
    namespaces:
      - devops-demo
    labelSelectors:
      "app": "user-service"
  stressors:
    cpu:
      workers: 2
      load: 80
  duration: "3m"
```

### Running the Experiment

```bash
# Save the above YAML to chaos/cpu-stress.yaml
kubectl apply -f chaos/cpu-stress.yaml

# Monitor CPU usage
kubectl top pods -n devops-demo

# Check if HPA triggers (if configured)
kubectl get hpa -n devops-demo
```

## Best Practices

### Before Running Experiments

1. **Notify the team** - Even in dev/staging environments
2. **Check baseline metrics** - Know your normal state
3. **Have rollback plan** - Know how to stop experiments quickly
4. **Monitor actively** - Watch dashboards during experiments
5. **Document results** - Record observations and learnings

### During Experiments

1. **Start small** - Begin with low-impact experiments
2. **Increase gradually** - Ramp up chaos intensity slowly
3. **Monitor continuously** - Watch for unexpected behavior
4. **Be ready to abort** - Stop if things go wrong

### After Experiments

1. **Analyze results** - Review metrics and logs
2. **Document findings** - What worked, what didn't
3. **Identify improvements** - Fix weaknesses discovered
4. **Share learnings** - Educate the team
5. **Update runbooks** - Improve incident response

## Common Issues

### Chaos Mesh Not Working

```bash
# Check Chaos Mesh components
kubectl get pods -n chaos-mesh

# Check logs
kubectl logs -n chaos-mesh -l app.kubernetes.io/component=controller-manager

# Verify RBAC permissions
kubectl auth can-i create podchaos --namespace=devops-demo
```

### Experiment Not Affecting Pods

```bash
# Verify label selectors match
kubectl get pods -n devops-demo --show-labels

# Check experiment status
kubectl describe podchaos <experiment-name> -n devops-demo

# View Chaos Mesh events
kubectl get events -n devops-demo --sort-by='.lastTimestamp'
```

### Services Not Recovering

```bash
# Check pod status
kubectl get pods -n devops-demo

# Force delete stuck pods
kubectl delete pod <pod-name> -n devops-demo --force --grace-period=0

# Restart deployment
kubectl rollout restart deployment/<deployment-name> -n devops-demo
```

## Metrics Collection

### Key Metrics to Track

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| Pod Restart Count | Number of pod restarts | > 5 in 10 min |
| Error Rate | Percentage of 5xx responses | > 5% |
| Request Latency P95 | 95th percentile latency | > 1000ms |
| Service Availability | Uptime percentage | < 99% |
| CPU Usage | CPU utilization | > 80% |
| Memory Usage | Memory utilization | > 90% |

### Prometheus Queries

```promql
# Error rate
rate(http_server_requests_seconds_count{status=~"5.."}[5m])

# Request latency P95
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))

# Pod restart rate
rate(kube_pod_container_status_restarts_total[15m])

# Service availability
up{job="kubernetes-pods"}
```

## Experiment Schedule

Recommended schedule for continuous chaos testing:

- **Daily**: Pod failure experiments (low intensity)
- **Weekly**: Network latency experiments
- **Monthly**: Full disaster recovery drills
- **Quarterly**: Multi-region failure simulations

## Safety Measures

### Blast Radius Limitation

Always use `mode: one` or `mode: fixed` with small numbers to limit impact:

```yaml
spec:
  mode: fixed
  value: "1"  # Only affect 1 pod at a time
```

### Time Limits

Always set reasonable durations:

```yaml
spec:
  duration: "2m"  # Experiment auto-stops after 2 minutes
```

### Namespace Isolation

Run experiments only in designated namespaces:

```yaml
spec:
  selector:
    namespaces:
      - devops-demo  # Never production!
```

## Resources

- [Chaos Mesh Documentation](https://chaos-mesh.org/docs/)
- [Principles of Chaos Engineering](https://principlesofchaos.org/)
- [Google SRE Book - Testing for Reliability](https://sre.google/sre-book/testing-reliability/)

---

**Remember**: The goal of chaos engineering is to build confidence in system resilience, not to break things!
