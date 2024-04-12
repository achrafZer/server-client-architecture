#!/bin/bash

# Become the root user
sudo su -

# Create two new users: user1 and user2
useradd user1
passwd user1 # Set password for user1
useradd user2
passwd user2 # Set password for user2

# Backup the /home directory
rsync -av /home/ /tmp/home.backup/

# Extract the UUID of the /home partition from the /etc/fstab file
UUID_HOME=$(grep "/home" /etc/fstab | awk '{print $1}' | cut -d= -f2)
# Explanation:
# - grep "/home" selects the line from /etc/fstab that includes "/home"
# - awk '{print $1}' extracts the first column (which contains UUID=...)
# - cut -d= -f2 removes the "UUID=" part and retains only the UUID value

# Unmount the /home directory
umount /home

# Format the partition with the obtained UUID as ext4
mkfs.ext4 -U $UUID_HOME /dev/sda3

# Change the filesystem type in /etc/fstab from xfs to ext4
sed -i -e '/home/s/xfs/ext4/' /etc/fstab

# Mount the /home directory
mount /home

# Restore the backup to the /home directory
rsync -av /tmp/home.backup/ /home/

# Add the updated /home entry to /etc/fstab with quota options
LINE_TO_ADD="UUID=$UUID_HOME /home ext4 defaults,usrquota,grpquota 1 2"
echo "$LINE_TO_ADD" | sudo tee -a "/etc/fstab" > /dev/null

# Reload system daemon configurations
systemctl daemon-reload

# Remount /home with the updated fstab entry
mount -o remount /home

# Check and create disk quotas for users and groups
quotacheck -cugmv /home

# Enable quotas on /home
quotaon -v /home

# Set a 5 GB hard disk quota for user1
USER_ID=user1
HARD_QUOTA=$((5 * 1024 * 1024)) # Calculate quota in KB (5 GB)
edquota -u $USER_ID -F vfsv0 -s '5000000B' -H '5000000B' # Set the soft and hard limits

