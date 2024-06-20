output "subnetwork" {
  value = google_compute_subnetwork.private.self_link
}

output "vpc" {
  value = google_compute_network.vpc.self_link
}

output "private_ip" {
  value = google_compute_global_address.private_ip.address

}

output "cidr_block" {
  value = google_compute_subnetwork.private.ip_cidr_range
}
