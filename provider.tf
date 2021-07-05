provider "google" {
    project     = var.gcp_project
    region      = var.region
    credentials = file(var.credentials)
}