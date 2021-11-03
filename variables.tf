/*
  All changes should be done here.
*/

#General scope

variable "machineType" {
  default = "e2-small" #Use these ones for testing. They're cheap and mimic our provisioning conditions.
}

#Network
variable "network"{
  default = "main"
}

variable "subnetwork"{
  default = "private-subnet"
}

variable "subnetworkRange"{
  default = "192.168.0.0/20"
}


#Cluster
#All subnets are assumed to be 24.
variable "clusterName" {
  default = "cluster"
}

variable "clusterZone" {
  default = "us-west2-a"
}

variable "initialNodeCount" {
  default = 3
}

variable "clusterSecondaryName"{
  default = "gke-pods"
}

variable "clusterServiceName"{
  default = "gke-services"
}

variable "clusterSecondaryRange"{
  default = "10.0.1.0/24"
}

variable "clusterServiceRange"{
  default = "10.0.2.0/24"
}

variable "masterCidr"{
  default = "172.16.24.0/24" #Most likely what's going to be used in production. Stick to this
}

variable "nodeCount" { #Stay on 3
  default = 3
}

variable "autoscaling_min_node_count" { #Stay on 3
  default = 3
}

variable "autoscaling_max_node_count" { #Stay on 3
  default = 3
}

variable "diskSize" { #Largest volume was considered.
  default = 50
}

variable "diskType" {
  default = "pd-standard"
}

#Compute
variable "jumpName" { #Our tunnel
  default = "jump-host"
}

#Other
variable "sshUser" {
  default = "user"
}

#ssh
/*I'm using WSL, but the project is on my host system.
  This is why some paths may point to linux environments and others to windows
  Either way, change these to your needs
  Also, make sure you don't mix up the private keys. Choose a different location
  for a different name such as op_rsa.pub.
*/
variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

#Outputs
output "clusterEndpoint" {
  value = google_container_cluster.gke-cluster.endpoint
}

output "instanceIp" {
  value = google_compute_instance.jump-host.network_interface.0.access_config.0.nat_ip
}