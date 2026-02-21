variable "host" {
  description = "The database host address."
  type        = string
}

variable "username" {
  description = "The database username."
  type        = string
}

variable "password" {
  description = "The database password."
  type        = string
  sensitive   = true
}

variable "db_names" {
  description = "A map of database names to create."
  type        = any
  default     = {}
}

provider "postgresql" {
  alias           = "creator"
  host            = var.host
  port            = 5432
  database        = "postgres"
  username        = var.username
  password        = var.password
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_database" "databases" {
  provider = postgresql.creator
  for_each = var.db_names

  name              = each.key
  owner             = "postgresadmin"
  connection_limit  = -1
  allow_connections = true
}
