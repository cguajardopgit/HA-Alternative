data "google_compute_zones" "available" {
    project = local.projectId
    region  = local.gcpRegion
}

data "google_compute_image" "provision-image" {
  name    = "centos-7-v20211028" #This is the wrong way to do it but I couldn't find a way to fetch the image by family
  project = "centos-cloud"
}

#Bastion
resource "google_compute_instance" "jump-host" {
  name         = var.jumpName
  project      = local.projectId
  machine_type = var.machineType
  zone         = data.google_compute_zones.available.names[0]
  tags         = ["ssh"]
  service_account {
    email = local.serviceAccount
    scopes = ["cloud-platform"]
  }
  boot_disk {
    initialize_params {
        image = data.google_compute_image.provision-image.self_link
    }
  }
  network_interface {
    network    = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {}
  }
  metadata = {
    ssh-keys       = "${var.sshUser}:${file(var.ssh_public_key)}"
    startup-script = file("./kubernetes-setup.sh") #This should allow me to use kubectl right after the first boot.
  }
  provisioner "file" {
    source = "./app"
    destination = "/home/user/"

    connection {
             type = "ssh"
             user = var.sshUser
             host = google_compute_instance.jump-host.network_interface.0.access_config.0.nat_ip
             private_key = file("~/.ssh/id_rsa") #CHANGE ME. (Just generate a new key pair)
             timeout = "3m"
             agent = "false"
    }
  }    

  depends_on = [google_container_node_pool.default]
}