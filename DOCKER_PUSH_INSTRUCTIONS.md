# Docker Hub Push Instructions

Since Docker login requires interactive password entry, you'll need to complete this step manually.

## Push Images to Docker Hub

### Step 1: Login to Docker Hub
```bash
docker login -u vit112
```
Enter your Docker Hub password or Personal Access Token when prompted.

> **Tip:** For better security, use a Personal Access Token instead of your password:
> - Visit https://app.docker.com/settings/personal-access-tokens
> - Create a new token with "Read, Write, Delete" permissions
> - Use the token as your password

### Step 2: Push All Images
```bash
# Push user-service
docker push vit112/user-service:latest

# Push product-service
docker push vit112/product-service:latest

# Push api-gateway
docker push vit112/api-gateway:latest
```

### Step 3: Verify Images on Docker Hub
Visit https://hub.docker.com/u/vit112 to see your published images.

## GitHub Actions Setup

To enable CI/CD pipeline:

1. Go to your GitHub repository
2. Navigate to: **Settings → Secrets and variables → Actions**
3. Add the following secrets:
   - `DOCKER_USERNAME`: `vit112`
   - `DOCKER_PASSWORD`: Your Docker Hub password or PAT
   - `KUBECONFIG`: (Optional) Base64-encoded kubeconfig for cloud deployment

## Quick Commands Reference

```bash
# Check local images
docker images | Select-String "vit112"

# Stop Docker Compose services
docker-compose down

# Start Docker Compose services
docker-compose up -d

# View service logs
docker-compose logs -f

# Deploy to Kubernetes (after pushing images)
minikube start --cpus=4 --memory=8192
kubectl apply -f k8s/
minikube service api-gateway -n devops-demo
```
