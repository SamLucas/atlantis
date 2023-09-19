################################################
################ Nginx Teste ###################
################################################

locals {
  nginx = {
    name       = "nginx-teste"
    repository = "https://charts.bitnami.com/bitnami"
    version    = "15.1.1"
    chart      = "nginx"
    namespace  = "nginx-teste2"
  }
}

output "config_nginx" {
  value = local.nginx
}
