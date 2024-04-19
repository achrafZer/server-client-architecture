#!/bin/bash

# Set Google's DNS server to resolve domain names
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Install RPC service which is used for remote procedure call protocols
dnf -y install rpcbind
# Restart the RPC service to apply any new configuration
systemctl restart rpcbind
# Enable RPC service to start automatically on system boot
systemctl enable rpcbind

# Install NFS utilities for setting up NFS file sharing
yum install nfs-utils
# Restart NFS server to apply any new configurations
systemctl restart nfs-server
# Enable NFS server to start automatically on system boot
systemctl enable nfs-server

# Modify network configuration for VM client C4 to connect it to PV1 network
ip addr add 192.168.1.40/24 dev enp0s3

# Check connectivity by pinging the server (SRV) from C4
# Please add the ping command here if you want to perform a test

# Create a directory on SRV to test sharing it via NFS with C4
mkdir /partage

# Add NFS export rules to the exports file for sharing the directory with specified network ranges
echo "/partage 192.168.1.0/24(rw)" >> /etc/exports
echo "/partage 192.168.2.0/24(rw)" >> /etc/exports

# Start NFS server to enable file sharing services
systemctl start nfs-server
# Ensure NFS server starts on boot
systemctl enable nfs-server

# Configure firewall to allow NFS operations
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
# Reload firewall rules to apply changes
sudo firewall-cmd --reload

exportfs -ra
