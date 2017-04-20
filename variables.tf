variable "aws_region" {
  default = "us-west-2"
}

variable "aws_profile" {
  description = "Name of AWS profile to use for API access."
  default     = "default"
}

variable "vpc_cidr" {
  description = "CIDR for build VPC"
  default     = "192.168.0.0/16"
}

variable "project" {
  description = "Default value for project tag."
  default     = "zestimate"
}

variable "zpid" {
  description = "Zillow property ID."
}

variable "zwsid" {
  description = "Zillow API ID."
}

variable "bucket_key" {
  description = "Location of Zestimate history file in S3."
  default     = "data/zestimate_history.csv"
}
