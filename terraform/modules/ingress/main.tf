# Ingress routing for foo.localhost and bar.localhost.
# Documentation: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1
#
# Purpose:
# - Expose the foo and bar echo services through ingress-nginx
# - Provide hostname-based routing
resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    dynamic "rule" {
      for_each = var.rules

      content {
        host = rule.value.host

        http {
          path {
            path      = "/"
            path_type = "Prefix"

            backend {
              service {
                name = rule.value.service_name
                port {
                  number = rule.value.service_port
                }
              }
            }
          }
        }
      }
    }
  }
}
