module "compute" {
  source                = "./compute"
  region                = var.region
  project               = var.gcp_project_name
  subnetwork            = module.network.subnetwork
  vpc                   = module.network.vpc
  frontend_port_name    = "http-frontend"
  backend_port_name     = "http-backend"
  frontend_port         = 3000
  backend_port          = 8002
  instance_group_name   = "prefect-webapp-intance-group"
  ssl_cert_name         = "${var.gcp_project_name}-ssl-cert"
  backend_ssl_cert_name = "${var.gcp_project_name}-backend-ssl-cert"
  domain                = var.domain
  cidr_block            = module.network.cidr_block

  depends_on = [module.project_services]
}
