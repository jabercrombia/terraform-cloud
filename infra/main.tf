terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  sensitive = true
}

variable "zone_id" {
  sensitive = true
}

resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "@"
  type    = "CNAME"
  content = "cname.vercel-dns.com"
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = var.zone_id
  name    = "www"
  type    = "CNAME"
  content = "cname.vercel-dns.com"
  proxied = true
}

resource "cloudflare_record" "blog_a_1" {
  zone_id = var.zone_id
  name    = "blog"
  type    = "A"
  content = "162.159.153.4"
  proxied = false
}

resource "cloudflare_record" "blog_a_2" {
  zone_id = var.zone_id
  name    = "blog"
  type    = "A"
  content = "162.159.152.4"
  proxied = false
}