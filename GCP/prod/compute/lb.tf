
/*
  This Terraform configuration defines a global address resource for a load balancer in Google Cloud Platform (GCP).

  Resource:
  - google_compute_global_address.default

  Description:
  - The `google_compute_global_address` resource creates a global IP address that can be used for load balancing.

  Configuration:
  - `name`: Specifies the name of the global address resource. In this example, it is set to "lb-ipv4-address".

  Usage:
  - This resource can be used in conjunction with other resources to create a load balancer in GCP.

  Note:
  - Make sure to configure the load balancer settings and associated resources accordingly.

  Reference:
  - Terraform Google Provider Documentation: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
*/
resource "google_compute_global_address" "default" {
  name         = "lb-ipv4-address"
  address_type = "EXTERNAL"

}


/*
  This resource block defines a Google Compute Engine managed SSL certificate for the Frontend.
  It is used to manage SSL certificates for HTTPS load balancers in Google Cloud Platform.

  - `name`: The name of the SSL certificate.
  - `managed.domains`: The list of domains associated with the SSL certificate.

*/
resource "google_compute_managed_ssl_certificate" "default" {
  name = var.ssl_cert_name
  managed {
    domains = [var.domain]
  }
}

/*
  This resource block defines a Google Compute Engine managed SSL certificate for the Backend.
  It is used to manage SSL certificates for HTTPS load balancers in Google Cloud Platform.

  - `name`: The name of the SSL certificate.
  - `managed.domains`: The list of domains associated with the SSL certificate.

*/
resource "google_compute_managed_ssl_certificate" "backend" {
  name = var.backend_ssl_cert_name
  managed {
    domains = ["api.${var.domain}"]
  }
}



/*
  This Terraform code defines a Google Cloud Platform (GCP) URL map resource named "webapp-map".
  The URL map is used to route incoming requests to the appropriate backend services based on the host and path.

  Resource Details:
  - Name: webapp-map
  - Default Service: google_compute_backend_service.frontend.self_link

  Host Rules:
  - Hosts: [var.domain]
    Path Matcher: frontend-path

  Path Matchers:
  - Name: frontend-path
    Default Service: google_compute_backend_service.frontend.self_link

  Host Rules:
  - Hosts: ["api.${var.domain}"]
    Path Matcher: backend-path

  Path Matchers:
  - Name: backend-path
    Default Service: google_compute_backend_service.backend.self_link
*/
resource "google_compute_url_map" "default" {
  name            = "webapp-map"
  default_service = google_compute_backend_service.frontend.self_link

  host_rule {
    hosts        = [var.domain]
    path_matcher = "frontend-path"
  }

  path_matcher {
    name            = "frontend-path"
    default_service = google_compute_backend_service.frontend.self_link
  }

  host_rule {
    hosts        = ["api.${var.domain}"]
    path_matcher = "backend-path"
  }

  path_matcher {
    name            = "backend-path"
    default_service = google_compute_backend_service.backend.self_link
  }
}



/*
  This resource block defines a Google Compute Engine Target HTTPS Proxy.
  It is used to configure a proxy that terminates HTTPS traffic and forwards it to a backend service.

  - `name`: Specifies the name of the target HTTPS proxy.
  - `url_map`: Specifies the URL map that defines the routing rules for the proxy.
  - `ssl_certificates`: Specifies the SSL certificates to be used for terminating HTTPS traffic.

*/
resource "google_compute_target_https_proxy" "default" {
  name             = "https-lb-proxy"
  url_map          = google_compute_url_map.default.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link, google_compute_managed_ssl_certificate.backend.self_link]
}


/*
  This resource block defines a Google Compute Engine global forwarding rule for HTTPS traffic.

  - `name`: Specifies the name of the forwarding rule.
  - `target`: Specifies the self link of the target HTTPS proxy associated with the forwarding rule.
  - `port_range`: Specifies the port range for the forwarding rule. In this case, it is set to "443" for HTTPS traffic.
  - `ip_address`: Specifies the IP address associated with the forwarding rule.

  This resource is used to route incoming HTTPS traffic to the appropriate target HTTPS proxy.
*/
resource "google_compute_global_forwarding_rule" "default" {
  name       = "https-content-rule"
  target     = google_compute_target_https_proxy.default.self_link
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}


/*
  This resource block defines a Google Compute Engine firewall rule that allows HTTPS traffic from the load balancer to instances.
  
  - name: Specifies the name of the firewall rule.
  - network: Specifies the VPC network where the firewall rule is applied.
  - direction: Specifies the direction of the traffic (INGRESS or EGRESS).
  - allow: Specifies the protocol and ports to allow traffic for.
  - source_ranges: Specifies the IP ranges that are allowed to send traffic to the instances.
  - target_tags: Specifies the target tags to apply this rule to specific instances.
*/
resource "google_compute_firewall" "allow_https_traffic_to_instances" {
  name      = "allow-https-traffic-to-instances"
  network   = var.vpc
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["${var.frontend_port}", "${var.backend_port}"]
  }

  // The source ranges should be the IP ranges of the load balancer
  // For Google Managed Load balancers, use the special IP range below to allow 
  // incoming traffic from the load balancer and health checks
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  // Target tags are used to apply this rule to specific instances
  target_tags = ["https-load-balancer-backend"]
}
