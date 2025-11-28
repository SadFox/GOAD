terraform {
  required_providers {
    serverspace = {
      source  = "itglobalcom/serverspace"
      # v0.3.2 is the latest as of 2025-01; allow any 0.3.x
      version = "~> 0.3"
    }
  }

  required_version = ">= 1.0.0"
}

# API token for Serverspace provider
variable "s2_token" {
  type      = string
  sensitive = true
  default   = "{{config.get_value('serverspace', 'api_token', '')}}"
}

# Location code in Serverspace (e.g., am2, nj3, kz)
variable "region" {
  description = "Serverspace location (use codes like am2, nj3, kz)"
  type        = string
  default     = "{{config.get_value('serverspace', 'location', 'ca')}}"
}

provider "serverspace" {
  key = var.s2_token
}
