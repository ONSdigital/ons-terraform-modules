resource "google_container_cluster" "address-index-api" {
  name                        = "${var.name}"
  project                     = "${var.project}"
  description                 = "Private Kubernetes Cluster - ${var.k_prefix}cluster environment"
  region                      = "${var.region}"  // NB: impacts node versions available if missing zone
  min_master_version          = "${var.k8s_min_master_version}"  // OPTIONAL and likely to be volatile
  node_version                = "${var.k8s_node_version}"        // OPTIONAL and likely to be volatile
  master_ipv4_cidr_block      = "${var.k8s_master_cidr}"
  network                     = "${var.network}"
  subnetwork                  = "${var.subnetwork}"
  private_cluster             = "true"
  enable_binary_authorization = "false"
  initial_node_count          = "${var.initial_node_count}"
  remove_default_node_pool    = true

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.k_prefix}services"
    services_secondary_range_name = "${var.k_prefix}pods"
  }


  master_authorized_networks_config {
    cidr_blocks = "${var.k8s_master_ip_whitelist}"
  }

  // this turns off cluster basic auth
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled  = "true"
    provider = "CALICO"
  }

  maintenance_policy {
    daily_maintenance_window {
      // GMT
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "default-node-pool" {
  name              = "default-node-pool"
  project           = "${var.project}"
  region            = "${var.region}"
  cluster           = "${google_container_cluster.address-index-api.name}"
  max_pods_per_node = "${var.max_pods_per_node}"
  node_count        = "${var.initial_node_count}"

  autoscaling {
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    machine_type = "${var.machine_type}"
    disk_size_gb = 100

    oauth_scopes = [
      "compute-rw",
      "storage-rw",
      "logging-write",
      "monitoring",
    ]

    // Prevent workloads not in hostNetwork from accessing certain VM metadata,
    // specifically kube-env, which contains Kubelet credentials, and the instance identity token
    workload_metadata_config {
      node_metadata = "SECURE"
    }

    service_account = "${google_service_account.compute.email}"
    tags            = ["${var.k_prefix}cluster", "default-node-pool"]
  }
}

// SERVICE ACCOUNT AND ROLES
resource "google_service_account" "compute" {
  project      = "${var.project}"
  account_id   = "compute"
  display_name = "Compute Engine service account"
}

