# --------------------
# Network
# --------------------
resource "google_compute_network" "vpc" {
  name                    = "teamavail-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "teamavail-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# --------------------
# GKE Cluster
# --------------------
resource "google_container_cluster" "gke" {
  name     = "teamavail-cluster"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "teamavail-nodes"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# --------------------
# Compute Engine VM with Postgres
# --------------------
resource "google_compute_instance" "postgres_vm" {
  name         = "teamavail-postgres"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {} # enable public IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y postgresql postgresql-contrib
    sudo -u postgres psql -c "CREATE DATABASE teamavail;"
    sudo -u postgres psql -c "CREATE USER teamavail_user WITH PASSWORD '${var.db_password}';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE teamavail TO teamavail_user;"
    sed -i "s/#listen_addresses =.*/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/*/main/pg_hba.conf
    systemctl restart postgresql
  EOT
}




terraform { 
  cloud { 
    
    organization = "mariomafdy" 

    workspaces { 
      name = "Konecta-task" 
    } 
  } 
}