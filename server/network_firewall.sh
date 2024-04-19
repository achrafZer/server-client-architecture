#j'ai commencé par activer via l'IHM de Virtual Box les Adapter 2 et 3 pour le serveur. Je leur ai également affecté respectivement les noms "PV1" et "PV2"
#Le but maintenant est de configurer les plages IP en utilisant l'outil nmtui
#Personnellement j'ai utilisé l'outil graphique nmtui (en exécutant la commande nmtui j'ai défini les différents paramètres). Or pour présenter ça dans un fichier sh j'ai traduit ces opérations en commandes shell sans passer par l'interface graphique.


nmcli con add type ethernet con-name PV1 ifname enp0s8 ip4 192.168.1.1/24 gw4 192.168.1.1
nmcli con mod PV1 ipv4.method manual

nmcli con add type ethernet con-name PV2 ifname enp0s9 ip4 192.168.2.1/24 gw4 192.168.2.1
nmcli con mod PV2 ipv4.method manual

ip addr show

#DHCP

dnf -y install dhcp-server

#!/bin/bash

# Contenu à ajouter à dhcpd.conf
#!/bin/bash

# Contenu à ajouter à dhcpd.conf
CONFIG_CONTENT=$(cat <<'EOF'
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.10 192.168.1.100;
    option domain-name-servers 192.168.1.1;
    option domain-name "id1.fr";
    option subnet-mask 255.255.255.0;
    option routers 192.168.1.1;
    default-lease-time 600;
    max-lease-time 7200;
}

subnet 192.168.2.0 netmask 255.255.255.0 {
    range 192.168.2.10 192.168.2.100;
    option domain-name-servers 192.168.2.1;
    option domain-name "id1.fr";
    option subnet-mask 255.255.255.0;
    option routers 192.168.2.1;
    default-lease-time 600;
    max-lease-time 7200;
}
EOF
)

# Vérification des privilèges de l'utilisateur
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi

# Sauvegarde de l'ancien fichier de configuration
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup

# Écriture du nouveau contenu dans le fichier de configuration DHCP
echo "$CONFIG_CONTENT" > /etc/dhcp/dhcpd.conf

# Afficher un message de succès
echo "La configuration DHCP a été mise à jour avec succès."

systemctl start dhcpd
systemctl enable dhcpd


# Définir SRV comme routeur par défaut
echo "net.ipv4.ip\_forward = 1" >> /etc/sysctl.conf
systemctl stop firewalld
systemctl disable firewalld
dnf -y install iptables-services

systemctl enable iptables
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
/usr/libexec/iptables/iptables.init save

iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP 
iptables-save > /etc/sysconfig/iptables



















