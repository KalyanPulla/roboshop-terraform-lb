env      = "dev"
location = "Denmark East"
rgname = "denmark-east-rg"
image_id = "/subscriptions/396632f7-adca-488d-bb48-22d93391890f/resourceGroups/denmark-east-rg/providers/Microsoft.Compute/galleries/rhel10/images/1.0.0/versions/1.0.0"
subnet_id = "/subscriptions/396632f7-adca-488d-bb48-22d93391890f/resourceGroups/denmark-east-rg/providers/Microsoft.Network/virtualNetworks/vnet-denmarkeast-1/subnets/snet-denmarkeast-1"

db = {
  mysql    = {}
  mongodb  = {}
  valkey   = {}
  rabbitmq = {}
}

apps = {
  catalogue    = {
    port = 8002
  }
  user         = {
    port = 8001
  }
  cart         = {
    port = 8003
  }
  shipping     = {
    port = 8004
  }
  payment      = {
    port = 8005
  }
  notification = {
    port = 8008
  }
  orders       = {
    port = 8007
  }
  ratings      = {
    port = 8006
  }
}

ui = {
  frontend = {
    port = 80
  }
}