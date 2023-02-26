module "main" {
  source = "github.com/vyusufcan/terraform/"
}

 module "docker-registry" {
  source = "./.terraform/modules/main/artifact_registry/"
  location = var.location
  project_name = var.project_name
  repository_id = var.repository_id
  respository_description = var.respository_description
  format = var.format
}


module "cloud-build-trigger" {
  source = "./.terraform/modules/main/cloud_build_trigger/"
  location = var.location
  project_name = var.project_name
  cloud_build_trigger_name = var.cloud_build_trigger_name
  branch_name = var.branch_name
  repo_name = var.repo_name
  
}


module "cloud-deploy-cloud-run-target" {
  source = "./.terraform/modules/main/cloud_deploy_cloud_run_target/"
  location = var.location
  project_name = var.project_name
  cloud_deploy_target_name = var.cloud_deploy_target_name
  require_approval = var.require_approval
  cloud_run_location = var.cloud_run_location

}

module "cloud-deploy-delivery-pipeline" {
  source = "./.terraform/modules/main/cloud_deploy_delivery_pipeline"
  location = var.location
  project_name = var.project_name
  delivery_pipeline_name = var.delivery_pipeline_name
  profiles = var.profiles
  target_id = module.cloud-deploy-cloud-run-target.cloud_deploy_cloud_run_target_id
}