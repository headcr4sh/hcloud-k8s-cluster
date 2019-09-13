variable "cluster_name" {
  description = "Name of the kubernetes cluster"
  type        = string
  default     = "panther"
}

variable "master_count" {
  type    = number
  default = 1
}

variable "docker_version" {
  description = "Docker CE version"
  type        = string
  default     = "18.06"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.15.0"
}
