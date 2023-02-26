resource "google_secret_manager_secret" "github-token-secret" {
  provider = google-beta
  secret_id = "github-token-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  provider = google-beta
  secret = google_secret_manager_secret.github-token-secret.id
  secret_data = file("my-github-token.txt")
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
  secret_id = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "my-connection" {
  provider = google-beta
  location = "europe-west1"
  name = "my-connection"

  github_config {
    app_installation_id = 34377217
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "my-repository" {
  provider = google-beta
  name = "my-repo"
  parent_connection = google_cloudbuildv2_connection.my-connection.id
  remote_uri = "https://github.com/vyusufcan/flask-app.git"
}

resource "google_cloudbuild_trigger" "repo-trigger" {
  provider = google-beta
  location = "europe-west1"

  repository_event_config {
    repository = google_cloudbuildv2_repository.my-repository.id
    push {
      branch = "main"
    }
  }

  filename = "cloudbuild.yaml"
}
