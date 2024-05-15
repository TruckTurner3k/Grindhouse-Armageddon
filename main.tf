terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  # Configuration options
  region = "us-east2"
  project = "carbon-sensor-419900"
  credentials = "carbon-sensor-419900-86735cb739be.json"
  }



resource "google_storage_bucket" "grindhouse42" {
  name          = "grindhouse"
  location      = "us"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }

  uniform_bucket_level_access = false
}

// Setting the bucket ACL to public read
resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.grindhouse42.name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for HTML files
resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.grindhouse42.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

// Public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}




output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.grindhouse42.name}/index.html"
}