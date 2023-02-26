terraform {
  backend "gcs" {
    bucket  = "vyusufcan-terraform-state"
    prefix  = "terraform-states"
  }
}
