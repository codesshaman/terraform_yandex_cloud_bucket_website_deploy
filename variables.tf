# variables.tf


variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "key_file" {
  description = "Path to authorized key json file"
  type        = string
}

variable "bucket_name" {
  description = "Some name for your bucket"
  type        = string
}

variable "zone_name" {
  description = "Some name for your cloud DNS zone"
  type        = string
}

variable "zone" {
  description = "Your domain with dot in the end"
  type        = string
}

variable "ip_address" {
  description = "Some IP adress for redirect"
  type        = string
}
