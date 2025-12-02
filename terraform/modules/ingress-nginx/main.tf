# Helm release for deploying the ingress-nginx controller.
# Documentation: https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
#
# Converts a Terraform expression map to a YAML string.
# https://developer.hashicorp.com/terraform/language/functions/yamlencode
#
# Helm chart version source:
# https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
#
# Purpose:
# - Install and manage ingress-nginx using Helm (version-pinned, reproducible)
resource "helm_release" "this" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.chart_version
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        replicaCount = 1

        service = {
          type = "NodePort"
          nodePorts = {
            http  = 30080
            https = 30443
          }
        }

        metrics = {
          enabled = true
        }
      }
    })
  ]
}