resource "k8s_manifest" "cainjector-service-account" {
  content = <<EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: cert-manager-cainjector
      namespace: ${var.namespace}
      labels:
        app: cainjector
        app.kubernetes.io/name: cainjector
        app.kubernetes.io/instance: cert-manager
EOF
}

resource "k8s_manifest" "cert-manager-service-account" {
  content = <<EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: cert-manager
      namespace: ${var.namespace}
      annotations:
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
EOF
}

resource "k8s_manifest" "webhook-service-account" {
  content = <<EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: cert-manager-webhook
      namespace: ${var.namespace}
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
EOF
}

resource "k8s_manifest" "cainjector-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: cert-manager-cainjector
      labels:
        app: cainjector
        app.kubernetes.io/name: cainjector
        app.kubernetes.io/instance: cert-manager
    rules:
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates"]
        verbs: ["get", "list", "watch"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch"]
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["get", "create", "update", "patch"]
      - apiGroups: ["admissionregistration.k8s.io"]
        resources: ["validatingwebhookconfigurations", "mutatingwebhookconfigurations"]
        verbs: ["get", "list", "watch", "update"]
      - apiGroups: ["apiregistration.k8s.io"]
        resources: ["apiservices"]
        verbs: ["get", "list", "watch", "update"]
      - apiGroups: ["apiextensions.k8s.io"]
        resources: ["customresourcedefinitions"]
        verbs: ["get", "list", "watch", "update"]
EOF
}

resource "k8s_manifest" "cert-manager-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-cainjector
      labels:
        app: cainjector
        app.kubernetes.io/name: cainjector
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cert-manager-cainjector
    subjects:
      - name: cert-manager-cainjector
        namespace: ${var.namespace}
        kind: ServiceAccount
EOF
}

resource "k8s_manifest" "cainjector-leader-election-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: Role
    metadata:
      name: cert-manager-cainjector-leaderelection
      namespace: kube-system
      labels:
        app: cainjector
        app.kubernetes.io/name: cainjector
        app.kubernetes.io/instance: cert-manager
    rules:
      # Used for leader election by the controller
      # TODO: refine the permission to *just* the leader election configmap
      - apiGroups: [""]
        resources: ["configmaps"]
        verbs: ["get", "create", "update", "patch"]
EOF
}

resource "k8s_manifest" "cainjector-leader-election-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: RoleBinding
    metadata:
      name: cert-manager-cainjector-leaderelection
      namespace: kube-system
      labels:
        app: cainjector
        app.kubernetes.io/name: cainjector
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: cert-manager-cainjector-leaderelection
    subjects:
      - apiGroup: ""
        kind: ServiceAccount
        name: cert-manager-cainjector
        namespace: ${var.namespace}
EOF
}

resource "k8s_manifest" "webhook-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-webhook-auth-delegator
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: system:auth-delegator
    subjects:
      - apiGroup: ""
        kind: ServiceAccount
        name: cert-manager-webhook
        namespace: ${var.namespace}
EOF
}

resource "k8s_manifest" "webhook-authentication-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: RoleBinding
    metadata:
      name: cert-manager-webhook-webhook-authentication-reader
      namespace: kube-system
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: extension-apiserver-authentication-reader
    subjects:
      - apiGroup: ""
        kind: ServiceAccount
        name: cert-manager-webhook
        namespace: ${var.namespace}
EOF
}

resource "k8s_manifest" "webhook-requester-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: cert-manager-webhook-webhook-requester
      labels:
        app: webhook
        app.kubernetes.io/name: webhook
        app.kubernetes.io/instance: cert-manager
    rules:
      - apiGroups:
          - admission.cert-manager.io
        resources:
          - certificates
          - certificaterequests
          - issuers
          - clusterissuers
        verbs:
          - create
EOF
}

resource "k8s_manifest" "leader-election-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: Role
    metadata:
      name: cert-manager-leaderelection
      namespace: kube-system
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    rules:
      # Used for leader election by the controller
      # TODO: refine the permission to *just* the leader election configmap
      - apiGroups: [""]
        resources: ["configmaps"]
        verbs: ["get", "create", "update", "patch"]
EOF
}

resource "k8s_manifest" "leader-election-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: RoleBinding
    metadata:
      name: cert-manager-leaderelection
      namespace: kube-system
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: cert-manager-leaderelection
    subjects:
      - apiGroup: ""
        kind: ServiceAccount
        name: cert-manager
        namespace: ${var.namespace}
EOF
}

resource "k8s_manifest" "issuers-controller-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: cert-manager-controller-issuers
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    rules:
      - apiGroups: ["cert-manager.io"]
        resources: ["issuers", "issuers/status"]
        verbs: ["update"]
      - apiGroups: ["cert-manager.io"]
        resources: ["issuers"]
        verbs: ["get", "list", "watch"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch", "create", "update", "delete"]
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["create", "patch"]
EOF
}

resource "k8s_manifest" "cluster-issuers-controller-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: cert-manager-controller-clusterissuers
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    rules:
      - apiGroups: ["cert-manager.io"]
        resources: ["clusterissuers", "clusterissuers/status"]
        verbs: ["update"]
      - apiGroups: ["cert-manager.io"]
        resources: ["clusterissuers"]
        verbs: ["get", "list", "watch"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch", "create", "update", "delete"]
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["create", "patch"]
EOF
}

resource "k8s_manifest" "certificates-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: cert-manager-controller-certificates
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    rules:
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates", "certificates/status", "certificaterequests", "certificaterequests/status"]
        verbs: ["update"]
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates", "certificaterequests", "clusterissuers", "issuers"]
        verbs: ["get", "list", "watch"]
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates/finalizers", "certificaterequests/finalizers"]
        verbs: ["update"]
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["orders"]
        verbs: ["create", "delete", "get", "list", "watch"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch", "create", "update", "delete"]
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["create", "patch"]
EOF
}

resource "k8s_manifest" "orders-controller-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: cert-manager-controller-orders
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    rules:
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["orders", "orders/status"]
        verbs: ["update"]
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["orders", "challenges"]
        verbs: ["get", "list", "watch"]
      - apiGroups: ["cert-manager.io"]
        resources: ["clusterissuers", "issuers"]
        verbs: ["get", "list", "watch"]
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["challenges"]
        verbs: ["create", "delete"]
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["orders/finalizers"]
        verbs: ["update"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch"]
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["create", "patch"]
EOF
}

resource "k8s_manifest" "challenges-controller-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: cert-manager-controller-challenges
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    rules:
      # Use to update challenge resource status
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["challenges", "challenges/status"]
        verbs: ["update"]
      # Used to watch challenge resources
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["challenges"]
        verbs: ["get", "list", "watch"]
      # Used to watch challenges, issuer and clusterissuer resources
      - apiGroups: ["cert-manager.io"]
        resources: ["issuers", "clusterissuers"]
        verbs: ["get", "list", "watch"]
      # Need to be able to retrieve ACME account private key to complete challenges
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch"]
      # Used to create events
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["create", "patch"]
      # HTTP01 rules
      - apiGroups: [""]
        resources: ["pods", "services"]
        verbs: ["get", "list", "watch", "create", "delete"]
      - apiGroups: ["extensions"]
        resources: ["ingresses"]
        verbs: ["get", "list", "watch", "create", "delete", "update"]
      - apiGroups: ["acme.cert-manager.io"]
        resources: ["challenges/finalizers"]
        verbs: ["update"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch"]
EOF
}

resource "k8s_manifest" "ingress-controller-shim-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: cert-manager-controller-ingress-shim
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    rules:
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates", "certificaterequests"]
        verbs: ["create", "update", "delete"]
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates", "certificaterequests", "issuers", "clusterissuers"]
        verbs: ["get", "list", "watch"]
      - apiGroups: ["extensions"]
        resources: ["ingresses"]
        verbs: ["get", "list", "watch"]
      - apiGroups: ["extensions"]
        resources: ["ingresses/finalizers"]
        verbs: ["update"]
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["create", "patch"]
EOF
}

resource "k8s_manifest" "issuers-controller-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-controller-issuers
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cert-manager-controller-issuers
    subjects:
      - name: cert-manager
        namespace: ${var.namespace}
        kind: ServiceAccount
EOF
}

resource "k8s_manifest" "cluster-issuers-controller-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-controller-clusterissuers
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cert-manager-controller-clusterissuers
    subjects:
      - name: cert-manager
        namespace: ${var.namespace}
        kind: ServiceAccount
EOF
}

resource "k8s_manifest" "certificates-controller-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-controller-certificates
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cert-manager-controller-certificates
    subjects:
      - name: cert-manager
        namespace: ${var.namespace}
        kind: ServiceAccount
EOF
}

resource "k8s_manifest" "orders-controller-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-controller-orders
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cert-manager-controller-orders
    subjects:
      - name: cert-manager
        namespace: ${var.namespace}
        kind: ServiceAccount
EOF
}

resource "k8s_manifest" "challenges-controller-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-controller-challenges
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cert-manager-controller-challenges
    subjects:
      - name: cert-manager
        namespace: ${var.namespace}
        kind: ServiceAccount
EOF
}

resource "k8s_manifest" "ingress-shim-controller-cluster-role-binding" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: cert-manager-controller-ingress-shim
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cert-manager-controller-ingress-shim
    subjects:
      - name: cert-manager
        namespace: ${var.namespace}
        kind: ServiceAccount
EOF
}

resource "k8s_manifest" "view-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: cert-manager-view
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
        rbac.authorization.k8s.io/aggregate-to-view: "true"
        rbac.authorization.k8s.io/aggregate-to-edit: "true"
        rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rules:
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates", "certificaterequests", "issuers"]
        verbs: ["get", "list", "watch"]
EOF
}

resource "k8s_manifest" "edit-cluster-role" {
  content = <<EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: cert-manager-edit
      labels:
        app: cert-manager
        app.kubernetes.io/name: cert-manager
        app.kubernetes.io/instance: cert-manager
        rbac.authorization.k8s.io/aggregate-to-edit: "true"
        rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rules:
      - apiGroups: ["cert-manager.io"]
        resources: ["certificates", "certificaterequests", "issuers"]
        verbs: ["create", "delete", "deletecollection", "patch", "update"]
EOF
}
