#!/bin/bash

# Set DNS for NetworkManager because it was not set by default.
# This avoids having to manually change /etc/resolv.conf after each connection.
nmcli con mod "enp0s3" ipv4.dns "8.8.8.8"
nmcli con up "enp0s3"
