# This data block defines a local file data source named "startup_script".
# It retrieves the contents of a file named "startup.sh" located in the same directory as this Terraform module.
# The script is used to install docker and docker-compose on the instance.
data "local_file" "startup_script" {
  filename = "${path.module}/startup.sh"
}

# This data block retrieves the available compute zones in the specified region.
# It uses the `google_compute_zones` data source to fetch the zones.
# The `region` variable is used to specify the region for which the zones should be retrieved.
# The `status` argument is set to "UP" to filter out zones that are not in an operational state.
data "google_compute_zones" "zones" {
  region = var.region
  status = "UP"
}

# prefect-webapp instance group
/*
  This resource block defines a Google Compute Engine instance group.
  An instance group is a collection of virtual machine instances that are managed as a single entity.
  It allows for easy scaling and load balancing of instances.

  The `name` parameter specifies the name of the instance group.
  The `zone` parameter specifies the zone where the instance group will be created.

  The `instances` parameter specifies the list of instances to include in the instance group.
  In this case, it includes a single instance with the self link of `google_compute_instance.prefect-webapp`.

  The `named_port` blocks define the named ports for the instance group.
  Each named port has a name and a port number.

  The `lifecycle` block specifies that changes to the `instances` and `zone` parameters should be ignored during updates.

*/

resource "google_compute_instance_group" "instance_group" {
  name = var.instance_group_name
  zone = data.google_compute_zones.zones.names[0]

  instances = [
    google_compute_instance.prefect-webapp.self_link
  ]

  named_port {
    name = var.frontend_port_name
    port = var.frontend_port
  }

  named_port {
    name = var.backend_port_name
    port = var.backend_port
  }

  lifecycle {
    ignore_changes = [instances, zone]
  }
}

/*
  This resource block defines a Google Compute Engine firewall rule that allows SSH access from a specific source range.

  Resource Name: google_compute_firewall.iap_ssh
  - The name of the firewall rule resource.

  Properties:
  - name (string): The name of the firewall rule.
  - network (string): The name or self_link of the network to attach the firewall rule to.
  - allow (block): The list of allowed protocols and ports.
    - protocol (string): The protocol to allow. In this case, it is set to "tcp".
    - ports (list(string)): The list of ports to allow. In this case, it is set to ["22"] for SSH.
  - source_ranges (list(string)): The list of source IP ranges to allow traffic from. In this case, it is set to ["35.235.240.0/20"]. This IP range corresponds to the IAP service.
*/
resource "google_compute_firewall" "iap_ssh" {
  name    = "allow-ssh-from-iap"
  network = var.vpc

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# create service account
resource "google_service_account" "my_service_account" {
  account_id   = "instance-service-account"
  display_name = "instance Service Account"
}

/**
 * This resource block defines the IAM member for accessing secrets in a Google Cloud Platform (GCP) project.
 * It grants the "secretmanager.secretAccessor" role to a service account.
 * This role allows the service account to access secrets in Secret Manager.

 * Arguments:
 * - project: The ID of the GCP project.
 * - role: The role to be granted to the member. In this case, it is "roles/secretmanager.secretAccessor".
 * - member: The member to whom the role is granted. It is in the format "serviceAccount:<service_account_email>".
 */
resource "google_project_iam_member" "secret_accessor" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

/**
 * Resource: google_project_iam_member
 * 
 * This resource represents a member's role in a Google Cloud project.
 * It grants the "artifactregistry.reader" role to a service account.
 * This role allows the service account to read artifacts from Artifact Registry.
 *
 * Arguments:
 * - project: The ID of the project where the role will be granted.
 * - role: The role to be granted. In this case, it is "roles/artifactregistry.reader".
 * - member: The member to whom the role will be granted. In this case, it is a service account.
 */
resource "google_project_iam_member" "artifcat_reader" {
  project = var.project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}
