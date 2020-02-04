resource "k8s_manifest" "cainjector-deployment" {
  content = <<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cert-manager-cainjector
      namespace: ${var.namespace}
      labels:
        app: cainjector
        app.kubernetes.io/name: cainjector
        app.kubernetes.io/instance: cert-manager
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: cainjector
          app.kubernetes.io/name: cainjector
          app.kubernetes.io/instance: cert-manager
      template:
        metadata:
          labels:
            app: cainjector
            app.kubernetes.io/name: cainjector
            app.kubernetes.io/instance: cert-manager
          annotations:
        spec:
          serviceAccountName: cert-manager-cainjector
          containers:
            - name: cert-manager
              image: ${var.cainjector_image}
              imagePullPolicy: IfNotPresent
              args:
                - --v=2
                - --leader-election-namespace=kube-system
              env:
                - name: POD_NAMESPACE
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.namespace
              resources:
                requests:
                  cpu: 250m
                  memory: 512Mi
EOF
}

resource "k8s_manifest" "controller-deployment" {
  content = <<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cert-manager
      namespace: ${var.namespace}
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: cert-manager
          app.kubernetes.io/name: cert-manager
      template:
        metadata:
          labels:
            app: cert-manager
            app.kubernetes.io/name: cert-manager
            app.kubernetes.io/instance: cert-manager
          annotations:
            prometheus.io/path: "/metrics"
            prometheus.io/scrape: 'true'
            prometheus.io/port: '9402'
        spec:
          serviceAccountName: cert-manager
          containers:
            - name: cert-manager
              image: ${var.controller_image}
              imagePullPolicy: IfNotPresent
              args:
                - --v=2
                - --cluster-resource-namespace=$(POD_NAMESPACE)
                - --leader-election-namespace=kube-system
                - --webhook-namespace=$(POD_NAMESPACE)
                - --webhook-ca-secret=cert-manager-webhook-ca
                - --webhook-serving-secret=cert-manager-webhook-tls
                - --webhook-dns-names=cert-manager-webhook,cert-manager-webhook.cert-manager,cert-manager-webhook.cert-manager.svc
              ports:
                - containerPort: 9402
                  protocol: TCP
              env:
                - name: POD_NAMESPACE
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.namespace
              resources:
                requests:
                  cpu: 250m
                  memory: 512Mi
EOF
}

resource "k8s_manifest" "webhook-deployment" {
  depends_on = [
    k8s_manifest.controller-deployment,
    k8s_manifest.cainjector-deployment,
  ]

  content = <<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cert-manager-webhook
      namespace: ${var.namespace}
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: webhook
          app.kubernetes.io/name: webhook
          app.kubernetes.io/instance: cert-manager
      template:
        metadata:
          labels:
            app: webhook
            app.kubernetes.io/name: webhook
            app.kubernetes.io/instance: cert-manager
          annotations:
        spec:
          serviceAccountName: cert-manager-webhook
          containers:
            - name: cert-manager
              image: ${var.webhook_image}
              imagePullPolicy: IfNotPresent
              args:
                - --v=2
                - --secure-port=10250
                - --tls-cert-file=/certs/tls.crt
                - --tls-private-key-file=/certs/tls.key
              livenessProbe:
                httpGet:
                  path: /livez
                  port: 6080
                  scheme: HTTP
              readinessProbe:
                httpGet:
                  path: /healthz
                  port: 6080
                  scheme: HTTP
              env:
                - name: POD_NAMESPACE
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.namespace
              resources:
                requests:
                  cpu: 250m
                  memory: 512Mi

              volumeMounts:
                - name: certs
                  mountPath: /certs
          volumes:
            - name: certs
              secret:
                secretName: "cert-manager-webhook-tls"
EOF
}
