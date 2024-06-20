

/**
 * This Terraform resource block defines a Google Compute Engine instance for Airbyte.
 * The instance is created with the specified machine type, tags, zone, and other configurations.
 * It uses an Ubuntu 20.04 LTS image as the boot disk and attaches it to the specified VPC and subnetwork.
 * The instance is associated with a service account that has the necessary scopes for accessing user info, compute resources, and storage.
 * The instance allows stopping for updates and has a lifecycle configuration to ignore changes to the zone and metadata startup script.
 */

resource "google_compute_instance" "airbyte" {
  name                      = "airbyte"
  machine_type              = "e2-medium"
  tags                      = ["airbyte", "allow-internal-port-8000"]
  zone                      = data.google_compute_zones.zones.names[0]
  allow_stopping_for_update = true # this allows the instance to be stopped for updates. This is useful for maintenance tasks.
  boot_disk {
    initialize_params {
      # ubuntu-2004-lts
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 50
      type  = "pd-standard" # HDD
    }
  }
  network_interface {
    network    = var.vpc
    subnetwork = var.subnetwork
  }
  metadata_startup_script = data.local_file.startup_script.content # This script will be executed when the instance starts up.
  service_account {
    email  = google_service_account.my_service_account.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    ignore_changes = [zone, metadata_startup_script]
  }
}

/**
 * This Terraform resource block defines a Google Compute Engine firewall rule to allow internal traffic on port 8000.
 * This allows backend to connect to the Airbyte instance on port 8000.
 * The rule allows TCP traffic on port 8000 from the specified CIDR block (internal IP range) and applies to instances with the target tag "allow-internal-port-8000".
 */
resource "google_compute_firewall" "allow_internal_8000" {
  name          = "allow-internal-port-8000"
  network       = var.vpc
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.cidr_block] # Adjust the CIDR block to match your internal IP range

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
  target_tags = ["allow-internal-port-8000"]
}
