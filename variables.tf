locals {
    labels = {
        "data-project" = var.data-project
    }
}

variable "project" {
    type= string
    description = "ID Google project"
}

variable "region" {
    type= string
    description = "Region Google project"
}

variable  "data-project" {
    type = string
    description = "Name of data pipeline project to use as resource prefix"
}

variable  "bk_csv" {
    type = string
    description = "bucket with csv's files"
}

variable  "bk_parquet" {
    type = string
    description = "bucket with parquet file, used to build a table"
}