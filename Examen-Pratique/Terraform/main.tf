terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {host = "tcp://192.168.64.98:2375"}

resource "docker_image" "salut_img" {
  name         = "chetouiiftikhar/salut:latest"
  keep_locally = false
}

resource "docker_container" "salut_container" {
  image = docker_image.salut_img.name
  name  = "salut_container"
  ports {
    internal = 8888
    external = 9999
  }
  restart = "unless-stopped"  # Politique de redémarrage
}

