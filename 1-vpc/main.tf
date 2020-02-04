module "vpc" {
  source = "./modules/vpc"

  vpc = {
    cidr = "10.0.0.0/8"
  }

  nat = {
    deploy        = true
    specification = "Small"

    eip = {
      bandwidth = 200
    }
  }

  private_vswitches = [
    "10.11.0.0/16",
    "10.12.0.0/16",
  ]

  data_vswitches = [
    "10.21.0.0/16",
    "10.22.0.0/16",
  ]

  security_group = {
    rules = [
      {
        type        = "egress"
        ip_protocol = "tcp"
        port_range  = "1/65535"
        cidr_ip     = "0.0.0.0/0"
      }
    ]
  }
}

output "vpc" {
  value = module.vpc.vpc
}

output "private-vswitches" {
  value = module.vpc.private-vswitches
}

output "data-vswitches" {
  value = module.vpc.data-vswitches
}
