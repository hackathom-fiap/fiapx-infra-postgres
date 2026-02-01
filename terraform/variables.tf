variable "aws_region" {
  description = "Região da AWS para implantar os recursos."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado para nomear recursos."
  type        = string
  default     = "soat-postgres"
}

variable "vpc_id" {
  description = "ID da VPC onde o banco de dados será implantado. Este valor deve ser fornecido no arquivo terraform.tfvars."
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs de sub-redes privadas para o banco de dados. Forneça este valor no arquivo terraform.tfvars."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "ID do Security Group da aplicação que precisará de acesso ao banco de dados. Forneça este valor no arquivo terraform.tfvars."
  type        = string
}

variable "db_instance_class" {
  description = "Classe da instância para o RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado para o banco de dados (em GB)."
  type        = number
  default     = 20
}

variable "create_databases" {

  description = "Flag para habilitar a criação dos bancos de dados lógicos via provider PostgreSQL."

  type        = bool

  default     = false

}



variable "db_names" {



  description = "Lista de nomes dos bancos de dados lógicos a serem criados dentro da instância única."



  type        = set(string)



  default     = ["fastdb", "orders-db", "customers-db", "products-db"]



}







variable "db_publicly_accessible" {
  description = "Define se a instância do banco de dados terá um endereço IP público."
  type        = bool
  default     = false
}

variable "db_allowed_cidr_blocks" {



  description = "Lista de blocos CIDR autorizados a acessar o banco de dados (ex: IP do GitHub Actions ou 0.0.0.0/0)."



  type        = list(string)



  default     = ["0.0.0.0/0"] # Use com cautela



}




