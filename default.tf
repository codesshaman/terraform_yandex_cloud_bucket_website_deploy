# default.tf

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.171.0"
    }
  }
}

locals {
    folder_id = var.folder_id
    cloud_id  = var.cloud_id
    key_file  = var.key_file
}

provider "yandex" {
    service_account_key_file    = local.key_file
    cloud_id                    = local.cloud_id
    folder_id                   = local.folder_id
    zone                        = "ru-central1-a"
}
