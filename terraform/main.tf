module "ingress_nginx" {
  source = "./modules/ingress-nginx"
}

module "prometheus" {
  source                 = "./modules/prometheus"
  grafana_admin_password = var.grafana_admin_password
}

module "foo" {
  source    = "./modules/http-echo"
  name      = "foo"
  namespace = var.namespace
  text      = "foo"
}

module "bar" {
  source    = "./modules/http-echo"
  name      = "bar"
  namespace = var.namespace
  text      = "bar"
}

module "ingress" {
  source    = "./modules/ingress"
  name      = "echo-ingress"
  namespace = var.namespace

  rules = [
    {
      host         = "foo.localhost"
      service_name = module.foo.service_name
      service_port = module.foo.service_port
    },
    {
      host         = "bar.localhost"
      service_name = module.bar.service_name
      service_port = module.bar.service_port
    }
  ]

  depends_on = [module.ingress_nginx]
}
