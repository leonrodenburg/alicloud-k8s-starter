locals {
  name   = "demo"
  image  = "leonrodenburg/alicloud-example-page:latest"
  port   = 80
  domain = "leon.onalibabacloud.com"
  path   = "/demo"
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name   = local.name
    labels = {
      app = local.name
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = local.name
      }
    }
    template {
      metadata {
        labels = {
          app = local.name
        }
      }
      spec {
        container {
          name  = local.name
          image = local.image

          port {
            container_port = local.port
          }

          resources {
            requests {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name        = local.name
    annotations = {
      "service.beta.kubernetes.io/alibaba-cloud-loadbalancer-address-type" = "intranet"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = local.name
    }

    port {
      port        = 80
      target_port = local.port
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name        = local.name
    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx"
      "cert-manager.io/cluster-issuer"                    = "letsencrypt"
      "nginx.ingress.kubernetes.io/rewrite-target"        = "/$1"
      "nginx.ingress.kubernetes.io/configuration-snippet" = "rewrite ^(${local.path})$ $1/ redirect;"
    }
  }

  spec {
    rule {
      host = local.domain

      http {
        path {
          backend {
            service_name = local.name
            service_port = 80
          }

          path = "${local.path}/(.*)"
        }
      }
    }

    tls {
      hosts       = [
        local.domain
      ]
      secret_name = "${local.name}-tls"
    }
  }
}
