output "grafana_nodeport" {
  value = 32000
}

output "prometheus_nodeport" {
  value = 32001
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = local.grafana_password
  sensitive   = true
}
