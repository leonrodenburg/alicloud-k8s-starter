provider "alicloud" {
  version = "~> 1.80"
}

provider "kubernetes" {
  version = "~> 1.10"

  config_path = "~/.kube/config"
}
