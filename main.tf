module "db" {
  for_each       = var.db
  source         = "./modules/vm"
  component_name = each.key
  rgname         = var.rgname
  image_id       = var.image_id
  subnet_id      = var.subnet_id
  env            = var.env
  vm_count       = 1
}

module "apps" {
  depends_on     = [module.db]
  for_each       = var.apps
  source         = "./modules/vm"
  component_name = each.key
  port           = each.value["port"]
  lb_type        = "private"
  rgname         = var.rgname
  image_id       = var.image_id
  subnet_id      = var.subnet_id
  env            = var.env
  vm_count       = 2
}

module "ui" {
  depends_on     = [module.apps]
  for_each       = var.ui
  source         = "./modules/vm"
  component_name = each.key
  port           = each.value["port"]
  lb_type        = "public"
  rgname         = var.rgname
  image_id       = var.image_id
  subnet_id      = var.subnet_id
  env            = var.env
  vm_count       = 2
}