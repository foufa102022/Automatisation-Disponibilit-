# veuillez préparer une VM vierge Ubuntu server 22.04 (portant votre prénom comme hostname) contenant :
- docker et docker compose
- vagrant
- terraform
- un box vagrant generic/ubuntu2204
- les images docker :
      + portainer/portainer-ce      
      + prom/prometheus
      + grafana/grafana-oss
      + prom/alertmanager
      + quay.io/prometheus/node-exporter
      + gcr.io/cadvisor/cadvisor
# Examen Pratique: enoncé 

Utilisez la VM-LAB déjà préparer portant votre prénom comme hostname pour effectuer
les tâches suivantes :
1. Activez l’accès par clés ssh à votre VM-LAB
2. Installer Portainer
3. Utilisez Vagrant pour créer une VM Ubuntu 22.04 server et utilisez Ansible pour
effectuer les opérations suivantes :
- Update et upgrade du système
- Installation docker
- Ajout de l'utilisateur 'vagrant' au groupe docker
4. Créez une application Spring Boot qui :
 Utilise Spring Boot Actuator pour le monitoring
 Expose une api /salutation (qui affiche 'Bonjour Master DevOps II') sur le
port 8888
5. Créez l’image docker de votre application Spring Boot (salutation) et mettez-le dans
votre docker hub
6. Utilisez Terraform (de la VM-LAB) pour installer dans la VM créer par Vagrant un
conteneur salutation qui utilise le port 9999 comme port externe
7. A partir de votre machine physique, testez l’accès à votre conteneur salutation
8. Dans votre VM-LAB, utilisez prometheus, grafana, alertmanger et node_exporter
pour :
- Monitorer le système linux de votre VM-LAB avec le dashboard grafana (id = 1860)
- Envoyez une alerte (Gmail ou Discord ou Telegram) quand l'espace disk disponible
est inferieur à 90%
Utilisez l’expression :
100 - (100 * node_filesystem_avail_bytes / node_filesystem_size_bytes) > 90
9. Mettez sur Github dans un entrepôt Examen-Pratique l’application Spring Boot et les
scripts crées.
