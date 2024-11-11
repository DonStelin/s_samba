#!/bin/bash

sudo apt update
sudo apt install -y samba

sudo systemctl status nmbd

sudo ufw status
sudo ufw enable
sudo ufw allow 'Samba'

mkdir -p ~/Publico/elisa
mkdir -p ~/Publico/publico

sudo useradd -M -d ~/Publico/elisa -s /usr/sbin/nologin -G sambashare elisa
sudo useradd -M -d ~/Publico/publico -s /usr/sbin/nologin -G sambashare adminsamba

sudo chown elisa:sambashare ~/Publico/elisa
sudo chown adminsamba:sambashare ~/Publico/publico

sudo chmod 2770 ~/Publico/elisa
sudo chmod 2770 ~/Publico/publico

echo -e "1234\n1234" | sudo smbpasswd -a elisa
sudo smbpasswd -e elisa
echo -e "1234\n1234" | sudo smbpasswd -a adminsamba
sudo smbpasswd -e adminsamba

sudo cp /etc/samba/smb.conf /etc/samba/smb.conf-bck
sudo bash -c 'cat >> /etc/samba/smb.conf <<EOL

[publico]
path = /home/ubuntu/Publico/publico
browseable = yes
read only = no
force create mode = 0660
force directory mode = 2770
valid users = @sambashare @adminsamba

[elisa]
path = /home/ubuntu/Publico/elisa
browseable = no
read only = no
force create mode = 0660
force directory mode = 2770
valid users = elisa @adminsamba
EOL'

sudo systemctl restart nmbd

sudo bash -c 'cat > /etc/network/interfaces <<EOL
# interfaces(5) file used by ifup(8) and ifdown(8)

auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
address 192.168.0.100
netmask 255.255.255.0
gateway 192.168.0.1
network 192.168.0.0
broadcast 192.168.0.255
EOL'

sudo systemctl restart networking

echo "PRAYGE"
