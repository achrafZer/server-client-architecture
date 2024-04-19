#!/bin/bash

# I started by enabling Adapter 2 and 3 in the Virtual Box UI for the server and named them "PV1" and "PV2".
# The goal now is to configure the IP ranges using the 'nmtui' tool.
# Personally, I used the graphical 'nmtui' tool by running the 'nmtui' command and setting the parameters. However, for this script, I've translated those operations into shell commands without using the graphical interface.

# Add a new Ethernet connection named "PV1" with manual IP configuration
nmcli con add type ethernet con-name PV1 ifname enp0s8 ip4 192.168.1.1/24 gw4 192.168.1.1
nmcli con mod PV1 ipv4.method manual  # Set the IPv4 method to manual for PV1

# Add a new Ethernet connection named "PV2" with manual IP configuration
nmcli con add type ethernet con-name PV2 ifname enp0s9 ip4 192.168.2.1/24 gw4 192.168.2.1
nmcli con mod PV2 ipv4.method manual  # Set the IPv4 method to manual for PV2

# Display current IP addresses on all network interfaces
ip addr show

# Install the DHCP server package
dnf -y install dhcp-server

# Content to be added to dhcpd.conf
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

# Check user privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Backup the old DHCP configuration file
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup

# Write the new DHCP configuration content to the configuration file
echo "$CONFIG_CONTENT" > /etc/dhcp/dhcpd.conf

# Display a success message
echo "The DHCP configuration has been successfully updated."

# Start and enable the DHCP server
systemctl start dhcpd
systemctl enable dhcpd

# Set the server (SRV) as the default router
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf  # Enable IP forwarding
systemctl stop firewalld  # Stop the firewall
systemctl disable firewalld  # Disable the firewall
dnf -y install iptables-services  # Install iptables services

systemctl enable iptables  # Enable iptables service
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE  # Setup NAT for outgoing traffic
/usr/libexec/iptables/iptables.init save  # Save iptables configuration

iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT  # Allow SSH from the 192.168.1.0/24 subnet
iptables -A INPUT -p tcp --dport 22 -j DROP  # Drop all other SSH traffic
iptables-save > /etc/sysconfig/iptables  # Save the iptables rules



















