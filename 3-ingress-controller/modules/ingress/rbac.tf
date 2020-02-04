resource "kubernetes_service_account" "nginx-ingress-serviceaccount" {
  metadata {
    name      = "nginx-ingress-serviceaccount"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }
}

resource "kubernetes_cluster_role" "nginx-ingress-clusterrole" {
  metadata {
    name   = "nginx-ingress-clusterrole"
    labels = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }

  rule {
    api_groups = [
      ""
    ]
    resources  = [
      "configmaps",
      "endpoints",
      "nodes",
      "pods",
      "secrets",
    ]
    verbs      = [
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [
      ""]
    resources  = [
      "nodes"
    ]
    verbs      = [
      "get"
    ]
  }

  rule {
    api_groups = [
      ""
    ]
    resources  = [
      "services"
    ]
    verbs      = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [
      ""
    ]
    resources  = [
      "events"
    ]
    verbs      = [
      "create",
      "patch"
    ]
  }

  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io"
    ]
    resources  = [
      "ingresses"
    ]
    verbs      = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io"
    ]
    resources  = [
      "ingresses/status"
    ]
    verbs      = [
      "update"
    ]
  }
}

resource "kubernetes_role" "nginx-ingress-role" {
  metadata {
    name      = "nginx-ingress-role"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }

  rule {
    api_groups = [
      ""
    ]
    resources  = [
      "configmaps",
      "pods",
      "secrets",
      "namespaces"
    ]
    verbs      = [
      "get"
    ]
  }

  rule {
    api_groups     = [
      ""
    ]
    resources      = [
      "configmaps"
    ]
    resource_names = [
      "ingress-controller-leader-nginx"
    ]
    verbs          = [
      "update"
    ]
  }

  rule {
    api_groups = [
      ""
    ]
    resources  = [
      "configmaps"
    ]
    verbs      = [
      "create"
    ]
  }

  rule {
    api_groups = [
      ""
    ]
    resources  = [
      "endpoints"
    ]
    verbs      = [
      "get"
    ]
  }
}

resource "kubernetes_role_binding" "nginx-ingress-rolebinding" {
  metadata {
    name      = "nginx-ingress-role-nisa-binding"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.nginx-ingress-role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx-ingress-serviceaccount.metadata[0].name
    namespace = kubernetes_service_account.nginx-ingress-serviceaccount.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "nginx-ingress-clusterrolebinding" {
  metadata {
    name   = "nginx-ingress-clusterrole-nisa-binding"
    labels = {
      "app.kubernetes.io/name"    = "nginx-ingress"
      "app.kubernetes.io/part-of" = "nginx-ingress"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx-ingress-clusterrole.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx-ingress-serviceaccount.metadata[0].name
    namespace = kubernetes_service_account.nginx-ingress-serviceaccount.metadata[0].namespace
  }
}
