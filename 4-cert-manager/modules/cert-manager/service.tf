resource "k8s_manifest" "cert-manager-service" {
  content = <<EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: cert-manager
      namespace: ${var.namespace}
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    spec:
      type: ClusterIP
      ports:
        - protocol: TCP
          port: 9402
          targetPort: 9402
      selector:
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
EOF
}

resource "k8s_manifest" "webhook-service" {
  content = <<EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: cert-manager-webhook
      namespace: ${var.namespace}
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
    spec:
      type: ClusterIP
      ports:
        - name: https
          port: 443
          targetPort: 10250
      selector:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
EOF
}


