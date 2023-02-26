output "cloud-build-sa-email" {
  value = google_project_service_identity.cloud_build_sa.email
}

output "docker-registry-id" {
  value = module.docker-registry.artifact-registry-id
}

output "docker-registry-format" {
  value = module.docker-registry.artifact-registry-format
}

output "cloud-build-trigger-id" {
  value = module.cloud-build-trigger.cloud-build-trigger-id
}

output "cloud-build-trigger-name" {
  value = module.cloud-build-trigger.cloud-build-trigger-name
}


output "cloud-deploy-cloud-run-target-id" {
  value = module.cloud-deploy-cloud-run-target.cloud_deploy_cloud_run_target_id
}

output "cloud-deploy-cloud-run-target-name" {
  value = module.cloud-deploy-cloud-run-target.cloud_deploy_cloud_run_target_name
}

output "cloud-deploy-delivery-pipeline-id" {
  value = module.cloud-deploy-delivery-pipeline.delivery-pipeline-id
}

output "cloud-deploy-delivery-pipeline-name" {
  value = module.cloud-deploy-delivery-pipeline.delivery-pipeline-name
}