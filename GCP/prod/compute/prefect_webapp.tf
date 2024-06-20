
/**
 * Resource: google_compute_instance.prefect-webapp
 * 
 * This resource defines a Google Compute Engine instance for the Prefect web application.
 * The instance will have the following componenets:
  * - Backend service for the frontend
  * - Prefecr proxy
  * - Prefect server
  * - Prefect Agent
  * - Celery worker
  * - Celery beat
  * - Redis
  * - Frontend service

  * The instance has a private IP and it will receive traffic from the load balancer.
  * The instance should be able to connect to airbyte and the database. Therefore configure it to be in the same network as the airbyte instance and the database.
 * 
 * Attributes:
 * - name: The name of the instance.
 * - machine_type: The machine type of the instance.
 * - tags: The tags associated with the instance.
 * - zone: The zone where the instance is located.
 * - allow_stopping_for_update: Whether the instance can be stopped for updates.
 * - boot_disk: The boot disk configuration of the instance.
 * - network_interface: The network interface configuration of the instance.
 * - metadata_startup_script: The startup script for the instance.
 * - service_account: The service account configuration for the instance.
 * - lifecycle: The lifecycle configuration for the instance.
 */

resource "google_compute_instance" "prefect-webapp" {
  name                      = "main"
  machine_type              = "e2-medium"
  tags                      = ["http-server", "https-server", "https-load-balancer-backend"]
  zone                      = data.google_compute_zones.zones.names[0]
  allow_stopping_for_update = true
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
  metadata_startup_script = data.local_file.startup_script.content
  service_account {
    email  = google_service_account.my_service_account.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    ignore_changes = [zone, metadata_startup_script]
  }

}

# frontend health check
/*
  This resource block defines a Google Compute Engine health check for the frontend service of the Prefect web application.

  The health check is used to monitor the health of the frontend service by periodically sending HTTP requests to the specified port and path.

  - `name`: The name of the health check.
  - `check_interval_sec`: The interval between health checks, in seconds.
  - `timeout_sec`: The maximum time to wait for a response from the backend, in seconds.
  - `healthy_threshold`: The number of consecutive successful health checks required to mark the backend as healthy.
  - `unhealthy_threshold`: The number of consecutive failed health checks required to mark the backend as unhealthy.

  The `http_health_check` block specifies the details of the HTTP health check:
  - `port`: The port number on which the health check requests will be sent.
  - `request_path`: The path of the HTTP request to be sent for health checks.

  This health check is used to ensure the availability and reliability of the frontend service in the production environment.
*/
resource "google_compute_health_check" "frontend" {
  name                = "frontend-service-health-check"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  http_health_check {
    port         = var.frontend_port
    request_path = "/api/auth/session"
  }
}

# frontend backend service. This is the service that will be used by the load balancer to route traffic to the frontend
/*
 * Resource: google_compute_backend_service.frontend
 * Description: This resource represents a backend service that handles load balancing for the frontend of the web application.
 * 
 * Attributes:
 * - name: The name of the backend service.
 * - load_balancing_scheme: The load balancing scheme for the backend service (EXTERNAL or INTERNAL).
 * - protocol: The protocol used by the backend service (HTTP or HTTPS).
 * - timeout_sec: The timeout value in seconds for the backend service.
 * - port_name: The name of the port to use for the backend service.
 * - health_checks: A list of health checks to be associated with the backend service.
 * - backend: The backend configuration for the backend service, including the instance group and balancing mode.
 */
resource "google_compute_backend_service" "frontend" {
  name                  = "frontend-service"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  timeout_sec           = 10
  port_name             = var.frontend_port_name
  health_checks         = [google_compute_health_check.frontend.self_link]


  backend {
    group           = google_compute_instance_group.instance_group.self_link
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

#  backend health check
/*
  This resource block defines a Google Compute Engine health check for the backend service.

  - `name`: Specifies the name of the health check.
  - `check_interval_sec`: Specifies the interval between health checks, in seconds.
  - `timeout_sec`: Specifies the maximum time to wait for a response from the backend, in seconds.
  - `healthy_threshold`: Specifies the number of consecutive successful health checks required to mark the backend as healthy.
  - `unhealthy_threshold`: Specifies the number of consecutive failed health checks required to mark the backend as unhealthy.

  The `http_health_check` block specifies the HTTP health check parameters:
  - `port`: Specifies the port number on which the health check request is sent.
  - `request_path`: Specifies the path of the health check request.

  This health check is used to monitor the health of the backend service.
*/
resource "google_compute_health_check" "backend" {
  name                = "backend-service-health-check"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = var.backend_port
    request_path = "/healthcheck"
  }
}

# backend backend service. This is the service that will be used by the load balancer to route traffic to the backend
/*
 * Resource: google_compute_backend_service.backend
 * Description: This resource represents a backend service that directs traffic to a group of instances.
 * 
 * Attributes:
 * - name (string): The name of the backend service.
 * - protocol (string): The protocol for the backend service. Valid values are "HTTP" or "HTTPS".
 * - timeout_sec (number): The number of seconds to wait for a backend to respond to a request before considering it a failed request.
 * - port_name (string): The name of the port to use for the backend service.
 * - health_checks (list): A list of health check URLs to be associated with the backend service.
 * - backend (block): The backend configuration for the backend service.
 *   - group (string): The self-link URL of the instance group to which traffic will be directed.
 *   - max_utilization (number): The maximum utilization of the backend service. Valid values are between 0 and 1.
 */
resource "google_compute_backend_service" "backend" {
  name        = "backend-service"
  protocol    = "HTTP"
  timeout_sec = 10
  port_name   = var.backend_port_name

  health_checks = [google_compute_health_check.backend.self_link]

  backend {
    group           = google_compute_instance_group.instance_group.self_link
    max_utilization = 0.8
  }
}
