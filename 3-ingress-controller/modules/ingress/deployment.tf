resource "kubernetes_deployment" "nginx-ingress-controller" {
  depends_on = [
    kubernetes_cluster_role_binding.nginx-ingress-clusterrolebinding,
    kubernetes_role_binding.nginx-ingress-rolebinding
  ]

  metadata {
    name      = "nginx-ingress-controller"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name": "nginx-ingress"
      "app.kubernetes.io/part-of": "nginx-ingress"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        "app.kubernetes.io/name": "nginx-ingress"
        "app.kubernetes.io/part-of": "nginx-ingress"
      }
    }

    template {
      metadata {
        labels      = {
          "app.kubernetes.io/name": "nginx-ingress"
          "app.kubernetes.io/part-of": "nginx-ingress"
        }
        annotations = {
          "prometheus.io/port"   = "10254"
          "prometheus.io/scrape" = "true"
        }
      }
      spec {
        termination_grace_period_seconds = 300

        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.nginx-ingress-serviceaccount.metadata[0].name

        container {
          name  = "nginx-ingress-controller"
          image = var.image
          args  = [
            "/nginx-ingress-controller",
            "--configmap=$(POD_NAMESPACE)/${kubernetes_config_map.nginx-configuration.metadata[0].name}",
            "--tcp-services-configmap=$(POD_NAMESPACE)/${kubernetes_config_map.tcp-services.metadata[0].name}",
            "--udp-services-configmap=$(POD_NAMESPACE)/${kubernetes_config_map.udp-services.metadata[0].name}",
            "--publish-service=$(POD_NAMESPACE)/${kubernetes_service.ingress.metadata[0].name}",
            "--annotations-prefix=nginx.ingress.kubernetes.io",
          ]

          resources {
            requests {
              cpu    = "250m"
              memory = "512Mi"
            }
          }

          security_context {
            allow_privilege_escalation = true
            capabilities {
              drop = [
                "ALL"
              ]
              add  = [
                "NET_ADMIN"
              ]
            }

            # need to run as root -> 0
            run_as_user  = 0
            run_as_group = 0
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          port {
            name           = "http"
            container_port = 80
          }

          port {
            name           = "https"
            container_port = 443
          }

          liveness_probe {
            failure_threshold     = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
          }

          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            period_seconds    = 10
            success_threshold = 1
            timeout_seconds   = 10
          }

          lifecycle {
            pre_stop {
              exec {
                command = [
                  "/wait-shutdown"
                ]
              }
            }
          }
        }
      }
    }
  }
}

output "deployment" {
  value = kubernetes_deployment.nginx-ingress-controller
}
