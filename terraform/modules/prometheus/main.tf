# Helm release for kube-prometheus-stack (Prometheus + Grafana).
# Documentation: https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
#
# Purpose:
# - Deploy cluster observability for CPU/memory/ingress metrics
# - Used during load testing to gather resource utilisation
resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.0"

  values = [
    yamlencode({
      grafana = {
        adminPassword = local.grafana_password
        service = {
          type = "NodePort"
          nodePort = 32000
        }
      },
      prometheus = {
        service = {
          type = "NodePort"
          nodePort = 32001
        }
      }
    })
  ]
}

locals {
  grafana_password = (
    var.grafana_admin_password != "" ?
    var.grafana_admin_password :
    random_password.grafana_admin.result
  )
}

resource "random_password" "grafana_admin" {
  length  = 8
  special = false
}
