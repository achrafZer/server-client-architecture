#j'ai commencé par activer via l'IHM de Virtual Box les Adapter 2 et 3 pour le serveur. Je leur ai également affecté respectivement les noms "PV1" et "PV2"
#Le but maintenant est de configurer les plages IP en utilisant l'outil nmtui
#Personnellement j'ai utilisé l'outil graphique nmtui (en exécutant la commande nmtui j'ai défini les différents paramètres). Or pour présenter ça dans un fichier sh j'ai traduit ces opérations en commandes shell sans passer par l'interface graphique.


nmcli con add type ethernet con-name PV1 ifname enp0s8 ip4 192.168.1.1/24 gw4 192.168.1.1
nmcli con mod PV1 ipv4.method manual

