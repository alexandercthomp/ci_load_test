variable "namespace" {
  description = "Namespace for workload deployments"
  type        = string
  default     = "default"
}

variable "grafana_admin_password" {
  description = "This varibale is used via Github secrets"
  type        = string
  default     = ""
  sensitive   = true
}
