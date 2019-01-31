##########################
#
# Do amend
#
##########################

variable "k8s_min_master_version"{
   description = "The minimum GKE master version"
   default = "1.11.6-gke.3"
}

variable "k8s_node_version"{
   description = "The minimum GKE master version"
   default = "1.11.6-gke.3"
}

// *********************
// Attention pls
// IF CHANGE MAKE SURE UNIQUE FOR CENSUS
// Otherwise break all
// *********************
variable "k8s_master_cidr" {
  description = "The Kubernetes master CIDR"
  default     = "10.69.0.0/28"
}

##########################
#
# Do not amend
#
##########################

variable "k_prefix" {
}

variable "k8s_master_ip_whitelist" {
  type = "list"
}

variable "network" {
  description = "The network to deploy to"
  default     = ""
}

variable "subnetwork" {
  description = "The subnetwork to deploy to"
  default     = ""
}

variable "initial_node_count" {
  default = "" 
}

variable "region" {
}

variable "max_pods_per_node" {
}

variable "min_node_count" {
}

variable "max_node_count" {
}

variable "machine_type" {
}

variable "project" {
}

variable "name"{
}