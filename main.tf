# main.tf

##############################
# GLOBAL CONFIG
##############################

locals {
  env         = terraform.workspace                    # qa / staging / production
  bucket_name = "${local.env}-${var.bucket_name}"      # Префикс окружения
}

##############################
# SERVICE ACCOUNT
##############################

resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "tf-test-sa"
}

##############################
# PERMISSIONS
##############################

resource "yandex_resourcemanager_folder_iam_member" "sa-storage-editor" {
  folder_id = local.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

##############################
# ACCESS KEYS
##############################

resource "yandex_iam_service_account_static_access_key" "sa-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for ${local.env}"
}

##############################
# STORAGE BUCKET
##############################

resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-key.secret_key
  bucket = local.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

##############################
# PUBLIC READ
##############################

resource "yandex_storage_bucket_grant" "public_read" {
  bucket = yandex_storage_bucket.test.id

  grant {
    permissions = ["READ"]
    type        = "Group"
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  }
}

##############################
# STATIC OBJECTS
##############################

resource "yandex_storage_object" "index_html" {
  bucket       = yandex_storage_bucket.test.bucket
  key          = "index.html"
  source       = "website/index.html"
  content_type = "text/html"
  source_hash = filemd5("website/index.html")
}

resource "yandex_storage_object" "static_files" {
  for_each = fileset("website/", "**/*")

  bucket       = yandex_storage_bucket.test.bucket
  key          = each.value
  source       = "website/${each.value}"

  content_type = lookup({
    ".html" = "text/html",
    ".css"  = "text/css",
    ".js"   = "application/javascript",
    ".png"  = "image/png",
    ".jpg"  = "image/jpeg",
    ".svg"  = "image/svg+xml",
    ".ico"  = "image/x-icon",
    ".woff"  = "font/woff",
    ".woff2"= "font/woff2"
  }, regex("\\.[^.]+$", each.value), "application/octet-stream")
  source_hash = filemd5("website/${each.value}")
}

