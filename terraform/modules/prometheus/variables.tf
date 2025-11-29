variable "namespace" {
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "This varibale is used via Github secrets"
  type        = string
  default     = ""
  sensitive   = true
}
