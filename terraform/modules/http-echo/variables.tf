variable "name" {
  type        = string
  description = "Name of the echo application"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace"
}

variable "text" {
  type        = string
  description = "Text to echo in response"
}
