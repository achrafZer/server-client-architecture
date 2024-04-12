sudo su -

useradd user1
passwd user1
useradd user2
passwd user2

#Attribution de 5 Go de quotas
rsync -av /home/ /tmp/home.backup/

UUID_HOME=$(cat /etc/fstab | fgrep /home | awk '{print $1'} | cut -d= -f2)
# cat résupère la table
# fgrep récupère la ligne qui concerne home (la partition où on veut appliquer les quitas)
# awk garde uniquement "UUID=..." et supprime les autres caractères de la ligne
# cut enlève la chaîne "UUID=" et ne laisse que le corps de l'UUID

unmount /home
mkfs.ext4 -U $UUID_HOME /dev/sda3
sed -i -e ’/home/s/xfs/ext4/’ /etc/fstab
mount /home
rsync -av /tmp/home.backup/ /home/ 

LINE_TO_ADD="UUID=$UUID_HOME /home ext4 default,usrquota,grpquota 1 2"

echo "$LINE_TO_ADD" | sudo tee -a "/etc/fstab" > /dev/null

systemctl daemon-reload
mount -o remount /home
quotacheck -cugmv /home
quotaon -v /home

USER_ID=user1
HARD_QUOTA=$((5 * 1024 * 1024))
edquota -u $USER_ID -F vfsv0 -s '5000000B' -H '5000000B'

