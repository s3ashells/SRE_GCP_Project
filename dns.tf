# Get the managed DNS zone
resource "google_dns_managed_zone" "gcp_coffeetime_dev" {
  provider = google
  name     = "gcp-coffeetime-dev"
  dns_name    = "static-${random_id.instance_id.hex}.com."
}

# Add the IP to the DNS
resource "google_dns_record_set" "static" {
  provider     = google
  name         = "static.${google_dns_managed_zone.gcp_coffeetime_dev.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.gcp_coffeetime_dev.name
  rrdatas      = [google_compute_global_address.static.address]
}