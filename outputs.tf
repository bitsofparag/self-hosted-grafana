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

output "grafana_dashboard_public_ip" {
  value = module.grafana_dashboard.public_ip
}

output "grafana_dashboard_public_dns" {
  value = module.grafana_dashboard.public_dns
}

output "grafana_dashboard_private_dns" {
  value = module.grafana_dashboard.private_dns
}

output "grafana_dashboard_ssh_config" {
  value = <<-EOS
Host           ${var.project_namespace}_grafana_dashboard_staging
Hostname       ${module.grafana_dashboard.public_ip}
User           ubuntu
IdentitiesOnly yes
EOS
}

output "grafana_dashboard_url" {
  value = "http://${module.grafana_dashboard.public_dns}:${var.grafana_proxy_port}"
}
