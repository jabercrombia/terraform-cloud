# Cloudflare + Vercel Terraform Guide (Stable Architecture)

This document defines a production-safe setup for managing DNS with Terraform and Cloudflare while deploying a frontend on Vercel.

---

# System Overview

Architecture flow:

```
Terraform
  ↓
Cloudflare DNS
  ↓
Vercel Hosting
  ↓
Next.js App
```

---

# Goals

* Single source of truth (Terraform)
* No manual DNS changes in Cloudflare UI
* Stable routing to Vercel
* Zero state drift
* Predictable deployments

---

# Cloudflare DNS Rules

Only use these record types:

## Root domain (@)

```hcl
resource "cloudflare_record" "root" {
  zone_id = var.zone_id
  name    = "@"
  type    = "CNAME"
  content = "cname.vercel-dns.com"
  proxied = false
}
```

## WWW domain

```hcl
resource "cloudflare_record" "www" {
  zone_id = var.zone_id
  name    = "www"
  type    = "CNAME"
  content = "cname.vercel-dns.com"
  proxied = false
}
```

---

# Do NOT use

* A records for root or www
* Wildcard (*) records (unless explicitly needed)
* Manual UI edits in Cloudflare
* Mixed A + CNAME setups

---

# 🧠 Terraform State Rules

## Use remote state (recommended)

* S3 backend OR Terraform Cloud
* Prevents local state loss or drift

## Workflow

```bash
terraform plan
terraform apply
```

NEVER skip plan in production.

---

# Provider configuration

```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
```

---

# Vercel Configuration

## Required setup:

* Set `www` as primary domain
* Ensure root redirects to www
* Enable automatic SSL

## Expected behavior:

* [https://jabercrombia.com](https://jabercrombia.com) → redirects to www
* [https://www.jabercrombia.com](https://www.jabercrombia.com) → serves app

---

# Verification Checklist

## DNS

```bash
dig jabercrombia.com
dig www.jabercrombia.com
```

Expected: CNAME resolution via Cloudflare edge

---

## Runtime

```bash
curl -I https://jabercrombia.com
```

Expected:

* 307 redirect to www
* or 200 OK on www
* server: cloudflare + vercel headers

---

# Common Failure Modes

## 1. Redirect loops

Cause: incorrect SSL mode in Cloudflare

Fix:

* Set SSL mode to "Full (strict)"

---

## 2. DNS mismatch

Cause: A records still exist

Fix:

* Remove all A records
* Use only CNAME → Vercel

---

## 3. Terraform state drift

Cause: manual Cloudflare changes

Fix:

```bash
terraform state list
terraform apply -refresh-only
```

---

# 🧠 Golden Rules

* Terraform owns DNS
* Cloudflare UI is read-only
* Vercel owns hosting
* No mixed record types for root domain

---

# Stable Architecture Outcome

When correctly configured:

* No DNS conflicts
* No import loops
* No manual fixes required
* Fully reproducible infra

---

# Summary

This setup ensures:

* deterministic infrastructure
* clean deployment pipeline
* production-grade reliability

---

End of guide.
