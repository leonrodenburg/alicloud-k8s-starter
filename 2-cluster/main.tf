data "alicloud_vpcs" "vpcs" {}
data "alicloud_vswitches" "vswitches" {
  name_regex = "private.+"
}

module "serverless-k8s-cluster" {
  source = "./modules/k8s/cluster"

  vpc_id     = data.alicloud_vpcs.vpcs.ids[0]
  vswitch_id = data.alicloud_vswitches.vswitches.ids[0]
  create_nat = false

  create_private_zone = true
  expose_api          = true
}

output "cluster" {
  value = module.serverless-k8s-cluster.cluster
}
