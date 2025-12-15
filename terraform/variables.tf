variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "devops-demo"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "user_service_image" {
  description = "Docker image for user service"
  type        = string
  default     = "vit112/user-service:latest"
}

variable "product_service_image" {
  description = "Docker image for product service"
  type        = string
  default     = "vit112/product-service:latest"
}

variable "api_gateway_image" {
  description = "Docker image for API gateway"
  type        = string
  default     = "vit112/api-gateway:latest"
}

variable "user_service_replicas" {
  description = "Number of replicas for user service"
  type        = number
  default     = 2
}

variable "product_service_replicas" {
  description = "Number of replicas for product service"
  type        = number
  default     = 2
}

variable "api_gateway_replicas" {
  description = "Number of replicas for API gateway"
  type        = number
  default     = 2
}
