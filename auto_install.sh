
#!/bin/bash

echo "Instalando Samba"
sudo apt install -y samba

echo "Verificando el estado del servicio nmbd..."
sudo service nmbd status

echo "Comprobando el estado del firewall UFW..."
if sudo ufw status | grep -qi "Status: inactive"; then
    echo "El firewall UFW está inactivo. Habilitándolo..."
    echo "y" | sudo ufw enable
    echo "UFW ha sido habilitado."
else
    echo "El firewall UFW ya está activo."
fi

echo "Verificando que el firewall tenga un perfil de aplicación para Samba..."
sudo ufw app list

if sudo ufw app info "samba" &>/dev/null; then
    echo "El perfil de Samba está disponible en el firewall."

    if ! sudo ufw status | grep -qi "samba"; then
        echo "El tráfico de entrada para Samba no está permitido. Habilitándolo..."
        sudo ufw allow "samba"
        echo "El tráfico de entrada para Samba ha sido permitido."
    else
        echo "El tráfico de entrada para Samba ya está permitido."
    fi
else
    echo "No se encontró un perfil de aplicación para Samba en UFW."
fi

echo "Creando el directorio 'Publico' en el directorio home del usuario actual..."
mkdir -p ~/Publico

echo "Creando las carpetas 'elisa' y 'publico' dentro de 'Publico'..."
mkdir -p ~/Publico/elisa
mkdir -p ~/Publico/publico
echo "Las carpetas 'elisa' y 'publico' han sido creadas dentro de 'Publico'."

echo "Creando los usuarios 'elisa' y 'adminsamba' para Samba..."
sudo useradd -M -d ~/Publico/elisa -s /usr/sbin/nologin -G sambashare elisa
sudo useradd -M -d ~/Publico/publico -s /usr/sbin/nologin -G sambashare adminsamba
echo "Los usuarios 'elisa' y 'adminsamba' han sido creados y asignados al grupo 'sambashare'."

echo "Cambiando la propiedad de las carpetas 'elisa' y 'publico' al grupo 'sambashare'..."
sudo chown elisa:sambashare ~/Publico/elisa
sudo chown adminsamba:sambashare ~/Publico/publico
echo "La propiedad de las carpetas ha sido actualizada correctamente."

echo "Asignando permisos 2770 a las carpetas 'elisa' y 'publico'..."
sudo chmod 2770 ~/Publico/elisa
sudo chmod 2770 ~/Publico/publico
echo "Permisos 2770 asignados a las carpetas 'elisa' y 'publico'."

echo "Asignando contraseñas y habilitando usuarios en Samba..."
echo -e "1234\n1234" | sudo smbpasswd -a elisa
sudo smbpasswd -e elisa
echo -e "1234\n1234" | sudo smbpasswd -a adminsamba
sudo smbpasswd -e adminsamba
echo "Los usuarios 'elisa' y 'adminsamba' han sido habilitados en Samba con la contraseña '1234'."

echo "Creando copia de respaldo de smb.conf..."
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf-bck
echo "Copia de respaldo creada como smb.conf-bck en /etc/samba."

echo "Configurando el archivo smb.conf para compartir las carpetas en la red..."
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
echo "Parámetros de configuración añadidos a smb.conf."

echo "Configurando el archivo /etc/network/interfaces para una dirección IP estática..."
sudo bash -c 'cat > /etc/network/interfaces <<EOL
# interfaces(5) file used by ifup(8) and ifdown(8)

# auto lo
# iface lo inet loopback

auto ens33
iface ens33 inet static
    address 192.168.0.100
    netmask 255.255.255.0
    gateway 192.168.0.1
    network 192.168.0.0
    broadcast 192.168.0.255
EOL'
echo "Configuración de red añadida a /etc/network/interfaces."

echo "Reiniciando el servicio nmbd para aplicar los cambios..."
sudo systemctl restart nmbd
echo "El servicio nmbd ha sido reiniciado y los cambios se han aplicado."

echo "Reiniciando el servicio de red para aplicar la nueva configuración de red..."
sudo systemctl restart networking
echo "El servicio de red ha sido reiniciado y la configuración de red estática se ha aplicado."

echo "LISTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
