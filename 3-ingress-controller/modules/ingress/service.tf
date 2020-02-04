resource "kubernetes_service" "ingress" {
  metadata {
    name      = "nginx-ingress-lb"
    namespace = var.namespace
    labels    = {
      app = "nginx-ingress-lb"
    }
  }

  spec {
    type                    = "LoadBalancer"
    external_traffic_policy = "Local"

    port {
      port        = 80
      name        = "http"
      target_port = 80
    }

    port {
      port        = 443
      name        = "https"
      target_port = 443
    }

    selector = {
      "app.kubernetes.io/name": "nginx-ingress"
      "app.kubernetes.io/part-of": "nginx-ingress"
    }
  }
}

output "service" {
  value = kubernetes_service.ingress
}
