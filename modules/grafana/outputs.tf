# modules/grafana/outputs.tf
 
output "internal_ip" {
  description = "IP interna de Grafana"
  value       = google_compute_instance.grafana.network_interface[0].network_ip
}
 
output "iap_tunnel_cmd" {
  description = "Copia y pega este comando para acceder a Grafana desde tu navegador"
  value = "gcloud compute start-iap-tunnel grafana 3000 --local-host-port=localhost:3000 --zone=${google_compute_instance.grafana.zone} --project=${var.project_id}"
}