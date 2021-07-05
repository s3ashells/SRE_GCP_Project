# Bucket to store website
resource "google_storage_bucket" "static" {
  provider = google
  name     = "${var.name}-static"
  location = "US"
}

# Make new objects public
resource "google_storage_default_object_access_control" "static_read" {
  bucket = google_storage_bucket.static.name
  role   = "READER"
  entity = "allUsers"
}