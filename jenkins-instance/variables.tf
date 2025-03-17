# variables.tf
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "<YOUR_PROJECT_ID>" # 기본값 설정 (필요에 따라 변경)
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1" # 기본값 설정 (필요에 따라 변경)
}

variable "zone" {
  description = "Google Cloud Zone"
  type        = string
  default     = "us-central1-a" # 기본값 설정 (필요에 따라 변경)
}