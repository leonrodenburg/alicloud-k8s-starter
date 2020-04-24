resource "k8s_manifest" "mutating-webhook-config" {
  content = <<EOF
    apiVersion: admissionregistration.k8s.io/v1beta1
    kind: MutatingWebhookConfiguration
    metadata:
      name: cert-manager-webhook
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
      annotations:
        cert-manager.io/inject-ca-from-secret: "cert-manager/cert-manager-webhook-tls"
    webhooks:
      - name: webhook.cert-manager.io
        rules:
          - apiGroups:
              - "cert-manager.io"
              - "acme.cert-manager.io"
            apiVersions:
              - v1alpha2
            operations:
              - CREATE
              - UPDATE
            resources:
              - "*/*"
        failurePolicy: Fail
        sideEffects: None
        clientConfig:
          service:
            name: cert-manager-webhook
            namespace: ${var.namespace}
            path: /mutate
EOF
}

resource "k8s_manifest" "validating-webhook-config" {
  content = <<EOF
    apiVersion: admissionregistration.k8s.io/v1beta1
    kind: ValidatingWebhookConfiguration
    metadata:
      name: cert-manager-webhook
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
        app.kubernetes.io/managed-by: Tiller
        helm.sh/chart: cert-manager-v0.12.0
      annotations:
        cert-manager.io/inject-ca-from-secret: "cert-manager/cert-manager-webhook-tls"
    webhooks:
      - name: webhook.cert-manager.io
        namespaceSelector:
          matchExpressions:
            - key: "cert-manager.io/disable-validation"
              operator: "NotIn"
              values:
                - "true"
            - key: "name"
              operator: "NotIn"
              values:
                - cert-manager
        rules:
          - apiGroups:
              - "cert-manager.io"
              - "acme.cert-manager.io"
            apiVersions:
              - v1alpha2
            operations:
              - CREATE
              - UPDATE
            resources:
              - "*/*"
        failurePolicy: Fail
        sideEffects: None
        clientConfig:
          service:
            name: cert-manager-webhook
            namespace: ${var.namespace}
            path: /mutate
EOF
}
