/*
  I tried the approach of having two separate subnets -a
  public and a private one- but for the purpoeses of this POC
  it was costly and it was going to make things confusing for
  everyone.
*/

#VPC
resource "google_compute_network" "main" { #Don't use the default network for this setup.
  name          = var.network
  project       = local.projectId
  auto_create_subnetworks = false
}

#Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnetwork
  project       = local.projectId
  ip_cidr_range = var.subnetworkRange
  region        = local.gcpRegion
  network       = google_compute_network.main.self_link

  secondary_ip_range = [
    {
      range_name    = var.clusterSecondaryName
      ip_cidr_range = var.clusterSecondaryRange
    },
    {
      range_name    = var.clusterServiceName
      ip_cidr_range = var.clusterServiceRange
    }
  ]
}

#External NAT IP
resource "google_compute_address" "nat" {
  name    = format("%s-nat-ip", var.clusterName) #Useful way I found to generate a name
  project = local.projectId
  region  = local.gcpRegion
}

#Cloud router
resource "google_compute_router" "router" {
  name    = format("%s-cloud-router", var.clusterName) #Useful way I found to generate a name
  project = local.projectId
  region  = local.gcpRegion
  network = google_compute_network.main.self_link
}

#Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = format("%s-cloud-nat", var.clusterName)
  project                            = local.projectId
  router                             = google_compute_router.router.name
  region                             = local.gcpRegion
  nat_ip_allocate_option             = "MANUAL_ONLY" #Only static, agreed upon IPs.
  nat_ips                            = [google_compute_address.nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.self_link

    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]

    secondary_ip_range_names = [
      google_compute_subnetwork.subnet.secondary_ip_range.0.range_name,
      google_compute_subnetwork.subnet.secondary_ip_range.1.range_name,
    ]
  }
}

#Firewall rules
resource "google_compute_firewall" "allow-bastion" {
  name    = "jump-host-ssh"
  project = local.projectId
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
}