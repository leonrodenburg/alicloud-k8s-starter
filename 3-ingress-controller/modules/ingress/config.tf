resource "kubernetes_config_map" "nginx-configuration" {
  metadata {
    name      = "nginx-configuration"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }

  data = {
    proxy-body-size             = "20m"
    proxy-connect-timeout       = "10"
    max-worker-connections      = "65536"
    worker-cpu-affinity         = "auto"
    server-tokens               = "false"
    allow-backend-server-header = "true"
    proxy-set-headers           = "${var.namespace}/${kubernetes_config_map.custom-headers.metadata[0].name}"
  }
}

resource "kubernetes_config_map" "custom-headers" {
  metadata {
    name      = "custom-headers"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }

  data = {
    # no custom headers yet
  }
}

resource "kubernetes_config_map" "tcp-services" {
  metadata {
    name      = "tcp-services"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }
}

resource "kubernetes_config_map" "udp-services" {
  metadata {
    name      = "udp-services"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }
}
