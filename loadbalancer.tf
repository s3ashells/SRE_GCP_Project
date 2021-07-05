# Reserve an external IP
resource "google_compute_global_address" "static" {
  provider = google
  name     = "static-lb-ip"
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "static" {
  provider    = google
  name        = "static-backend"
  description = "Contains files needed by the static"
  bucket_name = google_storage_bucket.static.name
  enable_cdn  = true
}

# Create HTTPS certificate
resource "google_compute_managed_ssl_certificate" "static" {
  provider = google
  name     = "static-cert"
  managed {
    domains = [google_dns_record_set.static.name]
  }
}

# GCP URL MAP
resource "google_compute_url_map" "static" {
  provider        = google
  name            = "static-url-map"
  default_service = google_compute_backend_bucket.static.self_link
  host_rule {
    hosts        = ["sreserver256.example.com"]
    path_matcher = "sreserver256"
  }
  path_matcher {
    name = "sreserver256"
    path_rule {
      paths = ["/api/*"]
      service = google_compute_instance.server.id
    }
  }
}

# GCP target proxy
resource "google_compute_target_https_proxy" "static" {
  provider         = google
  name             = "static-target-proxy"
  url_map          = google_compute_url_map.static.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.static.self_link]
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  provider              = google
  name                  = "static-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.static.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.static.self_link
}