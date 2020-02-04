resource "k8s_manifest" "letsencrypt-cluster-issuer" {
  depends_on = [
    k8s_manifest.cainjector-deployment,
    k8s_manifest.controller-deployment,
    k8s_manifest.webhook-deployment,
    k8s_manifest.cluster-issuer,
  ]
  content    = <<EOF
    apiVersion: cert-manager.io/v1alpha2
    kind: ClusterIssuer
    metadata:
      name: letsencrypt
    spec:
      acme:
        email: ${var.letsencrypt_email}
        server: ${var.letsencrypt_server}
        privateKeySecretRef:
          name: cert-manager-account-key
        solvers:
          - http01:
              ingress:
                class: nginx
                serviceType: ClusterIP

EOF
}
