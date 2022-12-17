## Declare variables here

variable "AZ-SUBSCRIPTION-ID"{}

variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "Resources location in Azure"
  default     = "southeastasia"
}

variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
}

variable "node_size" {
  type        = string
  description = "AKS per node size"
  default     = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default = "1.19.9"
}

variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
  default     = 3
}

variable "acr_name" {
  type        = string
  description = "ACR name"
}