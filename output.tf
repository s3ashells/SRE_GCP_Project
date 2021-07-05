// A variable for extracting the external IP address of the instance
output "consul-ip" {
  value = google_compute_instance.consul.network_interface.0.access_config.0.nat_ip
}

output "server-ip" {
  value = google_compute_instance.server.network_interface.0.access_config.0.nat_ip
}