#!/bin/bash

# Set DNS for NetworkManager because it was not set by default.
# This avoids having to manually change /etc/resolv.conf after each connection.
nmcli con mod "enp0s3" ipv4.dns "8.8.8.8"
nmcli con up "enp0s3"

# Install NIS (Network Information Service) server and tools.
dnf -y install ypserv yp-tools

# Set the NIS domain name in the network configuration file.
echo "NISDOMAIN=mydomain" >> /etc/sysconfig/network

# Set the domain name for the system.
domainname mydomain

# Initialize the NIS maps and add the localhost as a NIS server.
/usr/lib64/yp/ypinit -m

# Start and enable the NIS server to run on system boot.
sudo systemctl start ypserv
sudo systemctl enable ypserv
