output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.devops_demo.metadata[0].name
}

output "user_service_url" {
  description = "User service URL"
  value       = "http://user-service.${var.namespace}.svc.cluster.local:8081"
}

output "product_service_url" {
  description = "Product service URL"
  value       = "http://product-service.${var.namespace}.svc.cluster.local:8082"
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "http://api-gateway.${var.namespace}.svc.cluster.local:3000"
}

output "prometheus_url" {
  description = "Prometheus URL (NodePort)"
  value       = "Access via: minikube service prometheus -n ${var.namespace}"
}

output "grafana_url" {
  description = "Grafana URL (NodePort)"
  value       = "Access via: minikube service grafana -n ${var.namespace}"
}
