output "airbyte_ip" {
  value = google_compute_instance.airbyte.network_interface.0.network_ip
}
