output "gke_cluster_name" {
  value = google_container_cluster.gke.name
}

output "gke_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "postgres_vm_ip" {
  value = google_compute_instance.postgres_vm.network_interface[0].access_config[0].nat_ip
}