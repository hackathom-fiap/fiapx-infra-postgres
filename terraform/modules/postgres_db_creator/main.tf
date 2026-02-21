terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22.0"
    }
  }
}

variable "db_names" {
  description = "A set of database names to create."
  type        = set(string)
  default     = []
}

# This resource will automatically use the 'postgresql' provider
# configuration passed in from the parent module.
resource "postgresql_database" "databases" {
  for_each = var.db_names

  name              = each.key
  owner             = "postgresadmin"
  connection_limit  = -1
  allow_connections = true
}
