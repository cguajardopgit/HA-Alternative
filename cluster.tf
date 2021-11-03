#Cluster
data "google_container_engine_versions" "gkeversion" {
    location = local.gcpRegion
    project  = local.projectId
}

resource "google_container_cluster" "gke-cluster" {
  name               = var.clusterName
  project            = local.projectId
  location           = var.clusterZone
  network            = google_compute_network.main.self_link
  subnetwork         = google_compute_subnetwork.subnet.self_link
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  logging_service    = "logging.googleapis.com/kubernetes"

  remove_default_node_pool = true
  initial_node_count       = var.initialNodeCount

  ip_allocation_policy {
    cluster_secondary_range_name  = var.clusterSecondaryName
    services_secondary_range_name = var.clusterServiceName
  }

  addons_config {
    http_load_balancing {
        disabled = true #We're using an external LB
    }
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.masterCidr
  }

  master_authorized_networks_config {}

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

#Pool
resource "google_container_node_pool" "default" {
  name       = "${var.clusterName}-node-pool"
  project    = local.projectId
  location   = var.clusterZone
  cluster    = google_container_cluster.gke-cluster.name
  node_count = var.nodeCount
  depends_on = [google_container_cluster.gke-cluster]

  autoscaling {
    min_node_count = var.autoscaling_min_node_count
    max_node_count = var.autoscaling_max_node_count
  }

  node_config {
    preemptible     = true
    machine_type    = var.machineType
    disk_size_gb    = var.diskSize
    disk_type       = var.diskType
    service_account = local.serviceAccount

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}