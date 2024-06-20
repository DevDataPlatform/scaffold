module "storage" {
  source           = "./storage"
  region           = var.region
  project_tag      = var.project_tag
  db_instance_name = "dalgo-db"
  db_name          = "dalgo-db"
  prefect_db_name  = "prefect-db"
  airbyte_db_name  = "airbyte-db"
  db_user          = "dalgo_user"
  prefect_db_user  = "prefect_user"
  airbyte_db_user  = "airbyte_user"
  vpc              = module.network.vpc
  db_instance_type = var.db_instance_type
  db_port          = 5432


  depends_on = [module.project_services, module.network]

}
