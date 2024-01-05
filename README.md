# Examen Pratique

Dans ce lab on a besoin de virtualisation imbriqué donc on doit l'ouvrir depuis le powershel de la machine hote par la commande suivante: 


```
 set-VMProcessor -VMName Ubuntu-Vagrant-ExposeVirtualizationExtensions $true
```


## Activation  d’accès par clés ssh à votre VM-LAB && Génération de clé SSH et Copie vers une Machine Cible

## Génération de la Clé SSH

Pour générer une paire de clés SSH sur votre machine locale, utilisez la commande suivante dans votre terminal :

```
 ssh-keygen

 ```
 ## Copie vers une Machine Cible

 Pour copier le clé SSH de votre machine locale vers votre cible utilisez la commande suivante dans votre terminal:
 
 ```
 ssh-copy-id @ip machinecible
 ```
 ## Installation Portainer
 pour lancer portainer  il suffit de taper,dans la racine de fichier docker-compose.yml, la commande : 
 ```
 docker-compose up -d 
 ```
 --> docker-compose.yml
 ```
version: "3"
 services:
    portainer:
         container_name: portainer
         image: portainer/portainer-ce:latest
         ports:
           - 9555:9443
         volumes:
           - data:/data
           - /var/run/docker.sock:/var/run/docker.sock
         restart: unless-stopped
 volumes:
    data:

 ```
 #  création d'une VM Ubuntu 22.04 server avec vagrant:
 pour crer une machine par vagrant on doit telecharger le box de Vbox du site <https://app.vagrantup.com/>
 ## les étapes 

 `vagrant init generic/ubuntu2204`
 `vagrant up` 
 puis configurer le vagrantfile selon les besoins

 ## Approvisionnement de la machine vagrant par ansible pour :
- Update et upgrade du système
- Installation docker
- Ajout de l'utilisateur 'vagrant' au groupe docker

--> playbook d'installation docker et ajout da vagrant dans le groupe docker 
```
---
- name: Configuration Docker
  hosts: ubuntu22
  become: true

  tasks:
    - name: Mise à jour des paquets
      apt:
        update_cache: yes

    - name: Installation de Docker
      apt:
        name: docker.io
        state: present
      become: true

    - name: Ajout de l'utilisateur vagrant au groupe docker
      user:
        name: vagrant
        groups: docker
        append: yes

    - name: Configuration pour permettre à l'utilisateur vagrant d'utiliser Docker sans sudo
      lineinfile:
        path: /etc/sudoers.d/vagrant_docker
        line: 'vagrant ALL=(ALL) NOPASSWD: /usr/bin/docker'
        state: present
        create: yes

```
--> playbook de configuration du docker pour que la machine doit accessibe via tcp:
```
---
- name: Configure and Verify Docker
  hosts: ubuntu22
  become: true

  tasks:

    - name: Create directory for Docker service configuration
      file:
        path: /etc/systemd/system/docker.service.d
        state: directory

    - name: Create options.conf file
      blockinfile:
        path: /etc/systemd/system/docker.service.d/options.conf
        block: |
        
          [Service]
          ExecStart=
          ExecStart=/usr/bin/dockerd -H unix:// -H tcp://0.0.0.0:2375
        create: yes
      notify: Reload Docker

    - name: Create daemon.json.backup file
      blockinfile:
        path: /etc/docker/daemon.json.backup
        block: |
          {
            "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]
          }
        create: yes
      notify: Reload Docker

    - name: Verify Docker service status
      systemd:
        name: docker
        state: started

    - name: Show Docker info if successful
      debug:
        var: docker_info.stdout_lines
      when: docker_info.rc == 0

  handlers:
    - name: Reload Docker
      systemd:
        name: docker
        state: reloaded

    - name: Restart Docker
      systemd:
        name: docker
        state: restarted


```
> ces deux playbook sont executé lors de l'execussion de vagrantfile

## Création de l'application Spring Boot de site <https://start.spring.io/;> et telechargement du projet
 
## Dockerisation de l'application spring boot
- d'abord on fait `mvn clean install `  de l'application puis on fait la construction de l'image en se basant sur dockerfile qui se trouve à la racine  par la commande `docker build -t usernameDockerHub/nom-image:tag . `
  
--> Dockerfile   
```
FROM openjdk:17-jdk-alpine
WORKDIR /app
EXPOSE 8888
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]

``` 
- pour deployer l'image dans dockerHub :
` docker login `
` docker push usernameDockerHub/nom-image:tag `

# Utilisez Terraform (de la VM-LAB) pour installer dans la VM créer par Vagrant un
conteneur salutation qui utilise le port 9999 comme port externe

--> main.tf 
```
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {host = "tcp://@IPciblevagrant:2375"}

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
```
````
terraform init
terraform apply

````
- pour consulter le conteneure lancer dans la ma chine vagrant on utilise la commande :
`docker -H tcp://@ipCibleVagrant:2375 ps `

> à partir de browser de windows on peut consulter le container lancer par terraform dans vagrantcible en tape : @IP cibleVagrant: 9999 


### Monitorer le système linux de votre VM-LAB avec le dashboard grafana en utilisant prometheus, grafana, alertmanger et node_exporter : 

- pour faire la tache de monitoring on doit d'abord placer les fichiers de configurations sous /etc
  
  * /etc/prometheus/prometheus.yml
  * /etc/prometheus/alert-rules.yml
  * /etc/alertmanager/alertmanager.yml
  > pour voir le contenu de ces fichiers consulter le dossier **monitoring** !!
# test de l'alerting 
> pour tester l'alert manager on a fait une petite modification dans le alert-rules.yml pour tester le systeme d'alerting en cas ou  le disk utilisé est inferieur à 1%

groups:
  - name: example
    rules:
      - alert: FilesystemSpaceLow
        expr: 100 - (100 * node_filesystem_avail_bytes / node_filesystem_size_bytes) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Filesystem space is running low"
          description: "Filesystem space is running low on instance {{$labels.instance}}"





