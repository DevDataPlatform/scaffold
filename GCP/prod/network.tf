module "network" {
  source      = "./network"
  region      = var.region
  project_tag = var.project_tag
  vpc_name    = "dalgo-vpc"
  cidr_block  = "10.3.0.0/24"
  depends_on  = [module.project_services]

}
