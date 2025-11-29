variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "rules" {
  type = list(object({
    host         = string
    service_name = string
    service_port = number
  }))
}
