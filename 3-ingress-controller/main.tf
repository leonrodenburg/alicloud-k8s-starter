module "ingress-controller" {
  source = "./modules/ingress"

  namespace = "kube-system"
  image     = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.28.0"
}
