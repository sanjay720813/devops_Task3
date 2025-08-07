terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# NGINX Image
resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

# MySQL Image
resource "docker_image" "mysql_image" {
  name = "mysql:8.0"
}

# Node.js Image (uses a basic Node.js demo app)
resource "docker_image" "node_image" {
  name = "node:18"
}

# MySQL Volume
resource "docker_volume" "mysql_data" {
  name = "mysql_data"
}

# NGINX Container
resource "docker_container" "nginx_container" {
  name  = "nginx_terraform"
  image = docker_image.nginx_image.name
  ports {
    internal = 80
    external = 8080
  }
}

# MySQL Container
resource "docker_container" "mysql_container" {
  name  = "mysql_terraform"
  image = docker_image.mysql_image.name

  ports {
    internal = 3306
    external = 3306
  }

  env = [
    "MYSQL_ROOT_PASSWORD=rootpass",
    "MYSQL_DATABASE=testdb"
  ]

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }
}

# Node.js Container
resource "docker_container" "node_container" {
  name  = "nodejs_terraform"
  image = docker_image.node_image.name

  ports {
    internal = 3000
    external = 3000
  }

  command = [
    "node",
    "-e",
    "require('http').createServer((req,res)=>res.end('Hello from Node.js')).listen(3000)"
  ]
}

