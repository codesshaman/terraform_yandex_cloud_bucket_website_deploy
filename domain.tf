# domain.tf

# ================== DNS-зона в Yandex Cloud ==================
resource "yandex_dns_zone" "main" {
  name        = var.zone_name
  zone        = var.zone
  public      = true
  folder_id   = var.folder_id
}

# ================== DNS-записи ==================
resource "yandex_dns_recordset" "a_root" {
  zone_id = yandex_dns_zone.main.id
  name    = "@."
  type    = "A"
  ttl     = 300
  data    = [var.ip_address]
}

resource "yandex_dns_recordset" "aaaa_root" {
  zone_id = yandex_dns_zone.main.id
  name    = "@."
  type    = "AAAA"
  ttl     = 300
  data    = [var.ip_address]
}

resource "yandex_dns_recordset" "www" {
  zone_id = yandex_dns_zone.main.id
  name    = "www."
  type    = "CNAME"
  ttl     = 300
  data    = [var.zone]
}

resource "yandex_dns_recordset" "mx" {
  zone_id = yandex_dns_zone.main.id
  name    = "@."
  type    = "MX"
  ttl     = 3600
  data    = ["10 mx.yandex.net."]
}

resource "yandex_dns_recordset" "spf" {
  zone_id = yandex_dns_zone.main.id
  name    = "@."
  type    = "TXT"
  ttl     = 3600
  data    = ["v=spf1 redirect=_spf.yandex.net"]
}
