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

        # Fix GitHub Actions runner networking issues
        # HostNetwork bypasses NodePort, kube-proxy, iptables, nftables
        hostNetwork = true
        dnsPolicy   = "ClusterFirstWithHostNet"

        admissionWebhooks = {
          enabled = false
          patch = {
            enabled = false
          }
        }
        
        service = {
          type = "ClusterIP"  # Not NodePort anymore
        }

        nodeSelector = {
          "ingress-ready" = "true"   # Must match Kind node label
        }

        # Optional but good for debugging
        metrics = {
          enabled = true
        }
      }
    })
  ]
}
