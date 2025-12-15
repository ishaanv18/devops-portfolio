# Backend Troubleshooting Guide

## Common Issues and Fixes

### Issue 1: Maven Build Failures (Java Services)

**Symptoms:**
- `mvn clean install` fails
- Compilation errors
- Dependency resolution errors

**Solutions:**

1. **Clear Maven cache:**
```bash
cd user-service
mvn dependency:purge-local-repository
mvn clean install
```

2. **Update Maven wrapper (if using mvnw):**
```bash
mvn -N io.takari:maven:wrapper
```

3. **Check Java version:**
```bash
java -version  # Should be Java 17
```

### Issue 2: npm Install Failures (API Gateway)

**Symptoms:**
- `npm install` fails
- Module not found errors
- Package resolution errors

**Solutions:**

1. **Clear npm cache:**
```bash
cd api-gateway
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

2. **Use specific Node version:**
```bash
node --version  # Should be Node 20+
```

3. **Install with legacy peer deps (if needed):**
```bash
npm install --legacy-peer-deps
```

### Issue 3: Port Already in Use

**Symptoms:**
- "Port 8081 is already in use"
- "Port 3000 is already in use"
- Services won't start

**Solutions:**

**Windows:**
```powershell
# Find process using port 8081
netstat -ano | findstr :8081

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or change port in application.yml / server.js
```

**Linux/Mac:**
```bash
# Find and kill process on port 8081
lsof -ti:8081 | xargs kill -9

# Or change port
```

### Issue 4: Database Connection Issues

**Symptoms:**
- "Unable to create initial connections of pool"
- H2 database errors
- JPA errors

**Solutions:**

1. **Check H2 configuration in application.yml:**
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:userdb
    driver-class-name: org.h2.Driver
    username: sa
    password: 
```

2. **Enable H2 console for debugging:**
```yaml
spring:
  h2:
    console:
      enabled: true
      path: /h2-console
```

Access at: `http://localhost:8081/h2-console`

### Issue 5: CORS Errors

**Symptoms:**
- "Access to XMLHttpRequest has been blocked by CORS policy"
- Frontend can't connect to backend

**Solutions:**

1. **API Gateway already has CORS enabled**, but you can customize:
```javascript
// In server.js
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true
}));
```

2. **For Spring Boot services, add:**
```java
@CrossOrigin(origins = "*")
@RestController
public class UserController {
  // ...
}
```

### Issue 6: Docker Build Failures

**Symptoms:**
- Docker build fails
- "Cannot find module" in Node.js
- Maven build fails in Docker

**Solutions:**

1. **Build with no cache:**
```bash
docker build --no-cache -t user-service:latest ./user-service
```

2. **Check Dockerfile syntax:**
```dockerfile
# Make sure COPY commands are correct
COPY pom.xml .
COPY src ./src
```

3. **For Node.js, ensure package files are copied:**
```dockerfile
COPY package*.json ./
RUN npm ci --only=production
```

### Issue 7: Kubernetes Pod CrashLoopBackOff

**Symptoms:**
- Pods keep restarting
- `kubectl get pods` shows CrashLoopBackOff

**Solutions:**

1. **Check pod logs:**
```bash
kubectl logs <pod-name> -n devops-demo
kubectl logs <pod-name> -n devops-demo --previous
```

2. **Check pod events:**
```bash
kubectl describe pod <pod-name> -n devops-demo
```

3. **Common fixes:**
   - Increase memory limits
   - Fix image pull policy (use `imagePullPolicy: Never` for local images)
   - Check health check timeouts

4. **Update deployment with local images:**
```yaml
spec:
  containers:
  - name: user-service
    image: devops-demo/user-service:latest
    imagePullPolicy: Never  # For minikube
```

### Issue 8: Service Not Accessible in Kubernetes

**Symptoms:**
- Can't access service via NodePort
- Service endpoints are empty

**Solutions:**

1. **Check service and endpoints:**
```bash
kubectl get svc -n devops-demo
kubectl get endpoints -n devops-demo
```

2. **Verify pod labels match service selector:**
```bash
kubectl get pods -n devops-demo --show-labels
kubectl describe svc user-service -n devops-demo
```

3. **For minikube, use:**
```bash
minikube service api-gateway -n devops-demo
```

### Issue 9: Prometheus Not Scraping Metrics

**Symptoms:**
- Targets show as "DOWN" in Prometheus
- No metrics visible

**Solutions:**

1. **Check pod annotations:**
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8081"
  prometheus.io/path: "/actuator/prometheus"
```

2. **Verify metrics endpoints:**
```bash
# For Java services
curl http://localhost:8081/actuator/prometheus

# For API Gateway
curl http://localhost:3000/metrics
```

3. **Check Prometheus RBAC:**
```bash
kubectl get clusterrolebinding prometheus -o yaml
```

### Issue 10: Tests Failing

**Symptoms:**
- `mvn test` fails
- `npm test` fails

**Solutions:**

1. **For Maven tests:**
```bash
cd user-service
mvn clean test -X  # Debug mode
```

2. **For npm tests:**
```bash
cd api-gateway
npm test -- --verbose
```

3. **Skip tests temporarily:**
```bash
mvn clean install -DskipTests
```

## Quick Diagnostic Commands

### Check if services are running locally:

```bash
# User Service
curl http://localhost:8081/api/users/health

# Product Service
curl http://localhost:8082/api/products/health

# API Gateway
curl http://localhost:3000/health
```

### Check Docker containers:

```bash
docker ps
docker logs <container-name>
docker inspect <container-name>
```

### Check Kubernetes pods:

```bash
kubectl get pods -n devops-demo
kubectl logs -f deployment/user-service -n devops-demo
kubectl exec -it <pod-name> -n devops-demo -- /bin/sh
```

### Test database connectivity:

```bash
# Inside Spring Boot pod
kubectl exec -it <pod-name> -n devops-demo -- wget -O- http://localhost:8081/h2-console
```

## Environment-Specific Fixes

### For Docker Compose:

```bash
# Rebuild all services
docker-compose build --no-cache

# Restart specific service
docker-compose restart user-service

# View logs
docker-compose logs -f user-service

# Clean up and restart
docker-compose down -v
docker-compose up -d
```

### For Kubernetes:

```bash
# Restart deployment
kubectl rollout restart deployment/user-service -n devops-demo

# Delete and recreate pod
kubectl delete pod <pod-name> -n devops-demo

# Scale down and up
kubectl scale deployment/user-service --replicas=0 -n devops-demo
kubectl scale deployment/user-service --replicas=2 -n devops-demo
```

## Still Having Issues?

1. **Check the logs** - Most issues are visible in logs
2. **Verify prerequisites** - Java 17, Node 20, Docker, kubectl
3. **Check resource availability** - CPU, memory, disk space
4. **Review configuration files** - application.yml, package.json
5. **Test locally first** - Before deploying to Kubernetes

## Getting Help

If you're still stuck, provide:
1. Error messages (full stack trace)
2. Which service is failing
3. How you're running it (Docker/K8s/local)
4. Output of diagnostic commands
5. Your environment (OS, versions)
