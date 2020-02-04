locals {
  domains = {
    "onalibabacloud.com" = "leon"
  }
}

data "kubernetes_service" "nginx-ingress" {
  metadata {
    namespace = "kube-system"
    name      = "nginx-ingress-lb"
  }
}

resource "alicloud_dns_record" "record" {
  for_each    = local.domains
  name        = each.key
  host_record = each.value
  type        = "A"
  value       = data.kubernetes_service.nginx-ingress.load_balancer_ingress[0].ip
}
