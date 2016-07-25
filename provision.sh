#!/bin/bash
#
# nbox provisioning script, for pwnage purposes.
# Works in Ubuntu 14.04
#
# (@javutin)

set -e

echo "[+] Start provisioning nbox"
wget http://apt.ntop.org/14.04/all/apt-ntop.deb
sudo dpkg -i apt-ntop.deb
sudo apt-get clean all
sudo apt-get update
sudo apt-get install -y pfring nprobe ntopng ntopng-data n2disk cento nbox

echo "[+] Finished provisioning nbox"
