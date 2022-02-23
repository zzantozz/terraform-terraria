#!/bin/bash -e

apt-get update
apt-get -y install unattended-upgrades

echo "${iptables_save}" | base64 -d > /etc/iptables.save
echo "${unattended_upgrades}" | base64 -d > /etc/apt/apt.conf.d/50unattended-upgrades

iptables-restore /etc/iptables.save

cd /root
wget https://raw.githubusercontent.com/theonemule/no-ip/master/no-ip.sh
echo "b7a781b1d455adba6856dfc489756afff56b7f90dbf6e1b22547c34d136103a4  no-ip.sh" | sha256sum -c || {
  echo "no-ip.sh script failed checksum" >&2
  exit 1
}
# This script seems to have a bug. It won't work without a config file.
touch no-ip-config
bash no-ip.sh -c=no-ip-config -u=${no_ip_user} -p=${no_ip_password} -h=${no_ip_hostname} -d=true
