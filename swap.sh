#!/bin/bash

echo "Instalando HTOP"
sudo apt install  htop

echo "Memoria swap actual:"
htop &
free -h

echo "Creando archivo de swap "
sudo fallocate -l 1G /swapfile1

echo "Modificando permisos del archivo swap"
sudo chmod 600 /swapfile1

echo "Formateando archivo swap"
sudo mkswap /swapfile1

echo "Activando el archivo"
sudo swapon /swapfile1

echo "Agregando el archivo swap"
echo '/swapfile1 swap swap defaults 0 0' | sudo tee -a /etc/fstab

echo "Modificando cosas"
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p


echo "Memoria swap actual:"
htop &
free -h
