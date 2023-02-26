terraform {
  backend "gcs" {
    bucket  = "vyusufcan-terraform-state-2"
    prefix  = "terraform-states"
  }
}
