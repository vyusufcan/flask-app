variable "location" {
  type = string
}

variable "project_id" {
  type = number
}


variable "project_name" {
  type = string
}

variable "secret_id" {
  type = string
}

variable "secret_data" {
  type = string
}

variable "github_connection_name" {
  type = string
}

variable "app_installation_id" {
  type = number
  default = 34377217
}

variable "repository_remote_uri" {
    type=string
}

variable "repository_name" {
  type=string
}

variable "docker_registry_id" {
  type=string
  
}

variable "docker_respository_description" {
  type = string
}

variable "format" {
  type=string

}

variable "repo_trigger_name" {
  type=string
}

variable "branch_name" {
  type=string
}

variable "cloud_deploy_target_name" {
  type = string
}

variable "require_approval" {
  type=bool
}

variable "delivery_pipeline_name" {
  type=string
}

variable "profiles" {
  type = list
  default = null
}