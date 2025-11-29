# Deployment for the http-echo application.
# Documentation: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment
#
# Purpose:
# - Run a simple echo server returning either "foo" or "bar"
resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          name  = "http-echo"
          image = "hashicorp/http-echo:0.2.3"

          args = [
            "-text=${var.text}"
          ]

          port {
            container_port = 5678
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 5678
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 5678
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# ClusterIP service exposing the http-echo deployment.
# Documentation: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service
#
# Purpose:
# - Provide a stable DNS endpoint for the deployment (foo/bar)
# - Expose port 80 internally for ingress to route traffic
resource "kubernetes_service" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = var.name
    }

    port {
      port        = 80
      target_port = 5678
    }
  }
}
