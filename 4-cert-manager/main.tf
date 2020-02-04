resource "kubernetes_namespace" "cert-manager-namespace" {
  metadata {
    name = "cert-manager"

    labels = {
      "app.kubernetes.io/name": "cert-manager"
      "app.kubernetes.io/part-of": "cert-manager"
    }
  }
}

module "k8s-cert-manager" {
  source = "./modules/cert-manager"

  namespace = kubernetes_namespace.cert-manager-namespace.metadata[0].name

  cainjector_image = "quay.io/jetstack/cert-manager-cainjector:v0.13.0"
  controller_image = "quay.io/jetstack/cert-manager-controller:v0.13.0"
  webhook_image    = "quay.io/jetstack/cert-manager-webhook:v0.13.0"

  letsencrypt_email  = "lrodenburg@xebia.com"
  letsencrypt_server = "https://acme-v02.api.letsencrypt.org/directory"
}
