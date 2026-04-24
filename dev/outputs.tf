output "dev_project_id" {
  value = module.project.project_id

}

output "grafana_internal_ip" {
  value = module.grafana.internal_ip
}

output "grafana_iap_cmd" {
  value = module.grafana.iap_tunnel_cmd
}

