module "main" {
  source = "github.com/vyusufcan/terraform/"
}

resource "google_secret_manager_secret" "github-token-secret" {
  provider = google-beta
  project = var.project_name
  secret_id = var.secret_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  provider = google-beta
  secret = google_secret_manager_secret.github-token-secret.id
  #secret_data = file("my-github-token.txt")
  secret_data = var.secret_data
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service_identity" "cloud_build_sa" {
  provider = google-beta
  project = data.google_project.project.project_id
  service = "cloudbuild.googleapis.com"
}


resource "google_project_iam_member" "cloud_build_sa_cloud_deploy_releaser" {
  project = data.google_project.project.project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${google_project_service_identity.cloud_build_sa.email}"
}

resource "google_project_iam_member" "cloud_build_sa_service_account_user" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_project_service_identity.cloud_build_sa.email}"
}

resource "google_project_iam_member" "cloud_build_sa_default_sa" {
  project = data.google_project.project.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_project_service_identity.cloud_build_sa.email}"
}

data "google_iam_policy" "p4sa-secretAccessor" {
  provider = google-beta
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${data.google_project.project.project_id}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  provider = google-beta
  project = var.project_name
  secret_id = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "github-connection" {
  provider = google-beta
  location = var.location
  name = var.github_connection_name
  project = var.project_name

  github_config {
    #app_installation_id = 34377217
    app_installation_id = var.app_installation_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "repository" {
  provider = google-beta
  name = var.repository_name
  parent_connection = google_cloudbuildv2_connection.github-connection.id
  #remote_uri = "https://github.com/vyusufcan/flask-app.git"
  remote_uri = var.repository_remote_uri
  project = var.project_name

}

resource "google_cloudbuild_trigger" "repo-trigger" {
  provider = google-beta
  location = var.location
  project = var.project_name
  name = var.repo_trigger_name

  repository_event_config {
    repository = google_cloudbuildv2_repository.repository.id
    push {
      branch = var.branch_name
    }
  }

  filename = "cloudbuild.yaml"
}

 module "docker-registry" {
  source = "./.terraform/modules/main/artifact_registry"
  location = var.location
  project_name = var.project_name
  repository_id = var.docker_registry_id
  respository_description = var.docker_respository_description
  format = var.format
}

module "cloud-deploy-cloud-run-target" {
  source = "./.terraform/modules/main/cloud_deploy_cloud_run_target/"
  location = var.location
  project_name = var.project_name
  cloud_deploy_target_name = var.cloud_deploy_target_name
  require_approval = var.require_approval
  cloud_run_location = "projects/${var.project_name}/locations/${var.location}"

}

module "cloud-deploy-delivery-pipeline" {
  source = "./.terraform/modules/main/cloud_deploy_delivery_pipeline"
  location = var.location
  project_name = var.project_name
  delivery_pipeline_name = var.delivery_pipeline_name
  profiles = var.profiles
  target_id = module.cloud-deploy-cloud-run-target.cloud_deploy_cloud_run_target_id
}