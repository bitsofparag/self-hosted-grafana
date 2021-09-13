output "grafana_password" {
  description = "The Grafana admin password"
  value       = random_password.grafana_password.result
  sensitive   = true
}

output "grafana_user" {
  description = "The Grafana admin user"
  value       = random_string.grafana_user.result
  sensitive   = false
}

output "grafana_dashboard_public_ips" {
  value = module.grafana_dashboard.public_ip
}

output "grafana_dashboard_public_dnses" {
  value = module.grafana_dashboard.public_dns
}

output "grafana_dashboard_private_ips" {
  value = module.grafana_dashboard.private_ip
}

output "grafana_dashboard_ssh_config" {
  value = <<-EOS
Host           ${var.project_namespace}_grafana_dashboard_staging
Hostname       ${module.grafana_dashboard.public_ip[0]}
User           ubuntu
IdentitiesOnly yes
EOS
}

output "grafana_dashboard_url" {
  value = "http://${module.grafana_dashboard.public_dns[0]}:${var.grafana_proxy_port}"
}
