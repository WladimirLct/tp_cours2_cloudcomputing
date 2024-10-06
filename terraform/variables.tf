variable "location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}