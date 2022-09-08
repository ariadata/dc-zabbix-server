# zabbix-server with docker-compose
[![Build Status](https://files.ariadata.co/file/ariadata_logo.png)](https://ariadata.co)

![](https://img.shields.io/github/stars/ariadata/dc-zabbix-server.svg)
![](https://img.shields.io/github/watchers/ariadata/dc-zabbix-server.svg)
![](https://img.shields.io/github/forks/ariadata/dc-zabbix-server.svg)

> This needs : [nginx-proxy-manager](https://github.com/ariadata/dc-nginxproxymanager) + [dockerhost](https://github.com/ariadata/dockerhost-sh)

[Manual install](https://www.digitalocean.com/community/tutorials/how-to-monitor-docker-using-zabbix-on-ubuntu-20-04)

---
#### 1- Change `timezone` and `hostname` :
```sh
sudo timedatectl set-timezone Europe/Istanbul
sudo hostnamectl set-hostname "zabbix-server"
```
#### *** Auto Install Steps 2 to 5
after this , goto step `6`
```sh
bash <(curl -sSL https://github.com/ariadata/dc-zabbix-server/raw/main/zabbix-server-steps-2-to-5.sh)
```
---
#### 2- Update and install `zabbix-agent2` :
```sh
cd ~
wget -O zabbix-6.0-ubuntu-focal.deb https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-1+ubuntu20.04_all.deb
sudo dpkg -i zabbix-6.0-ubuntu-focal.deb && sudo rm -f zabbix-6.0-ubuntu-focal.deb
sudo apt -y update
sudo apt install -y zabbix-agent2
sudo apt -y upgrade
```
#### 3- config and enable `zabbix_agent2.conf` :
```sh
sudo sed -i 's/Server=127.0.0.1/Server=127.0.0.1,172.16.238.5/g' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/ServerActive=127.0.0.1/ServerActive=127.0.0.1,172.16.238.5/g' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/Hostname=Zabbix server/Hostname=zabbix-server/g' /etc/zabbix/zabbix_agent2.conf
sudo ufw allow 10050/tcp
sudo systemctl enable --now zabbix-agent2
sudo usermod -aG docker zabbix
sudo systemctl restart zabbix-agent2
```
#### 4- Clone this repo and cd into it, edit configs :
```sh
git clone https://github.com/ariadata/dc-zabbix-server.git dc-zabbix-server && cd dc-zabbix-server && rm -rf .git
sudo sed -i "s|PHP_TZ=.*|PHP_TZ=$(cat /etc/timezone)|g" ./env_vars/.env_web
sudo echo -n "$(shuf -er -n32  {A..Z} {a..z} {0..9} | tr -d '\n')" > ./env_vars/.POSTGRES_PASSWORD
```
#### 5- pull and run docker-compose:
```sh
docker-compose up -d
```
#### 6- Goto Nginx-Proxy-Manager admin panel and add this stack as proxy-host :
> Domain : `Your-FQDN` you must pointed it before!
> 
> Schema : `http`
> 
> Name or IP : `zabbix-web-nginx-pgsql`
> 
> Port : `8080`
>
> Config SSL Part

#### 7- goto web GUI `https://Your-FQDN` and login with:
User : `Admin`

Pass : `zabbix`

#### 8- In web gui , goto `Configuration`>`Hosts`:
> 1- Edit default item

> 2- change Host name to : `zabbix-server`

> 3- in Interface part, add `host.docker.internal` to dns part and set type to `DNS`

> 7- Click Update

#### 9- update and clear cache in zabbix-server:
```sh
docker-compose exec zabbix-server zabbix_server -R config_cache_reload
# reboot server
sudo reboot
```
#### 10- after reboot , ach to default problems and close them.

Done!
