#!/bin/sh
set -e
clear

cd ~
wget -O zabbix-6.0-ubuntu-focal.deb https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-1+ubuntu20.04_all.deb
sudo dpkg -i zabbix-6.0-ubuntu-focal.deb && sudo rm -f zabbix-6.0-ubuntu-focal.deb
sudo apt -y update
sudo apt install -y zabbix-agent2
sudo apt -y upgrade

sudo sed -i 's/Server=127.0.0.1/Server=127.0.0.1,172.16.238.5/g' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/ServerActive=127.0.0.1/ServerActive=127.0.0.1,172.16.238.5/g' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/Hostname=Zabbix server/Hostname=zabbix-server/g' /etc/zabbix/zabbix_agent2.conf
sudo ufw allow 10050/tcp
sudo systemctl enable --now zabbix-agent2
sudo usermod -aG docker zabbix
sudo systemctl restart zabbix-agent2

git clone https://github.com/ariadata/dc-zabbix-server.git dc-zabbix-server && cd dc-zabbix-server && rm -rf .git zabbix-server-steps-2-to-5.sh
sudo sed -i "s|PHP_TZ=.*|PHP_TZ=$(cat /etc/timezone)|g" ./env_vars/.env_web
sudo echo -n "$(shuf -er -n32  {A..Z} {a..z} {0..9} | tr -d '\n')" > ./env_vars/.POSTGRES_PASSWORD

docker-compose up -d
