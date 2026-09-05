terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

variable "app_version" {
  type = string
}

variable "blue_port" {
  type    = number
  default = 3001
}

variable "green_port" {
  type    = number
  default = 3002
}

resource "docker_image" "application" {
  name = "devops-app:${var.app_version}"

  keep_locally = true
}

resource "docker_container" "blue" {
  name  = "devops-blue"
  image = docker_image.application.name

  env = [
    "APP_VERSION=${var.app_version}",
    "APP_COLOR=blue",
    "NODE_ENV=production"
  ]

  ports {
    internal = 3000
    external = var.blue_port
  }
}

resource "docker_container" "green" {
  name  = "devops-green"
  image = docker_image.application.name

  env = [
    "APP_VERSION=${var.app_version}",
    "APP_COLOR=green",
    "NODE_ENV=production"
  ]

  ports {
    internal = 3000
    external = var.green_port
  }
}