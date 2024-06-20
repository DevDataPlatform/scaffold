# VPC

/*
  This Terraform code defines a Google Compute Engine network resource.
  
  Resource Name: google_compute_network.vpc
  
  Description:
  - The network resource represents a Virtual Private Cloud (VPC) network in Google Cloud Platform (GCP).
  
  Configuration:
  - name: The name of the VPC network. It is set using the variable var.vpc_name.
  - auto_create_subnetworks: Specifies whether subnetworks should be automatically created in this network. Set to false.
  - delete_default_routes_on_create: Specifies whether the default routes should be deleted when creating this network. Set to true.
*/
resource "google_compute_network" "vpc" {
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

# private subnetwork
/*
  This resource block defines a Google Compute Engine subnetwork in a VPC.


  - `name`: Specifies the name of the subnetwork. It is derived from the `vpc_name` variable.
  - `ip_cidr_range`: Specifies the IP address range for the subnetwork.
  - `network`: Specifies the self link of the VPC network.
  - `region`: Specifies the region where the subnetwork will be created.

  This resource block is used to define a private subnetwork within a VPC.
*/

resource "google_compute_subnetwork" "private" {
  name          = "${var.vpc_name}-private"
  ip_cidr_range = var.cidr_block
  network       = google_compute_network.vpc.self_link
  region        = var.region
}

# Create private IP
/*
  This resource block defines a Google Compute Engine global address for a private IP.
  It is used for VPC peering and has an internal address type.

  - `name`: The name of the global address, which is derived from the VPC name.
  - `purpose`: The purpose of the global address, which is set to "VPC_PEERING".
  - `address_type`: The type of the address, which is set to "INTERNAL".
  - `prefix_length`: The prefix length of the address, which is set to 16.
  - `network`: The self link of the VPC network resource.

  This resource is created as part of the VPC infrastructure in the production environment.
*/
resource "google_compute_global_address" "private_ip" {
  name          = "${var.vpc_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.self_link
}

/*
 * Resource: google_service_networking_connection.private_vpc_connection
 * Description: Creates a private VPC connection to enable private access to Google services.
 * 
 * Attributes:
 * - network: The ID of the VPC network to create the connection in.
 * - service: The name of the service to connect to. In this case, it is "servicenetworking.googleapis.com".
 * - reserved_peering_ranges: The list of reserved IP ranges to be used for peering with the service.
 */
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}

# VPC router
resource "google_compute_router" "vpc_router" {
  name    = "${var.vpc_name}-router"
  network = google_compute_network.vpc.self_link
}

# NAT gateway
/*
  This resource block defines a Google Compute Engine NAT (Network Address Translation) configuration.
  NAT allows instances without external IP addresses to communicate with the internet by translating their private IP addresses to public IP addresses.

  - name: Specifies the name of the NAT configuration, which is derived from the VPC name.
  - router: Specifies the name of the VPC router to associate with the NAT configuration.
  - region: Specifies the region where the VPC router is located.
  - nat_ip_allocate_option: Specifies the IP allocation option for NAT. In this case, it is set to "AUTO_ONLY" which means that only automatic IP allocation is allowed.
  - source_subnetwork_ip_ranges_to_nat: Specifies the IP ranges to be NATed. In this case, it is set to "ALL_SUBNETWORKS_ALL_IP_RANGES" which means that all IP ranges in all subnetworks will be NATed.
*/
resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.vpc_router.name
  region                             = google_compute_router.vpc_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Internet route
/*
  This resource block defines a Google Compute Engine route for internet traffic.
  The route allows traffic destined for the internet to be routed through the default internet gateway.
*/

resource "google_compute_route" "internet" {
  name             = "internet-route"
  network          = google_compute_network.vpc.self_link
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}
