#!/usr/bin/env bash

# update / upgrade
apt-get -y update && apt-get -y upgrade

# install required packages
apt-get install -y build-essential fail2ban ufw nano git git-core curl nginx chkrootkit mailutils libsasl2-modules logwatch libdate-manip-perl

#config ssh
sudo nano etc/ssh/sshd_config
# ----------------------------------------------------------------------
Port 2936

service ssh restart
# ----------------------------------------------------------------------

# Config firewall
ufw allow 25
ufw allow 80
ufw allow 443
ufw allow 2936
ufw enable
ufw status verbose

nano /etc/rc.local
# ----------------------------------------------------------------------
ufw enable
# ----------------------------------------------------------------------

# config fail2ban
sudo nano /etc/fail2ban/jail.local
# ----------------------------------------------------------------------
ignoreip = 127.0.0.1/8 your_home_IP
findtime = 3600
maxretry = 6
mta = mail
destemail = eduardo.gch@gmail.com
sendername = Fail2BanAlerts
# ----------------------------------------------------------------------

# config git
git config --global user.name "Server"
git config --global user.email eduardo.gch@gmail.com
git config --global url."https://".insteadOf git://
git config --global http.sslVerify false
git config --global color.ui true

# Install VPN
wget https://raw.github.com/viljoviitanen/setup-simple-pptp-vpn/master/setup.sh
sudo sh setup.sh

# Speedtest
wget -O speedtest-cli https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py
chmod +x speedtest-cli
./speedtest-cli

# Node
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash
nvm install node
nvm use node
npm config set strict-ssl false
npm config set registry http://registry.npmjs.org/
npm install -g npm node-gyp node-sass pm2 bower gulp mocha karma-cli

# nginx
sudo mkdir -p /var/www/example.com/html
sudo mkdir -p /var/www/test.com/html
sudo chmod -R 755 /var/www

rm /etc/nginx/sites-enabled/default
nano /etc/nginx/sites-available/example.com
nano /etc/nginx/sites-available/test.com
# ----------------------------------------------------------------------
server {
    listen 80;
    listen [::]:80;
    root /var/www/test.com/html;
    index index.html index.htm;
    server_name test.com www.test.com;
    location / {
        try_files $uri $uri/ =404;
    }
}
# ----------------------------------------------------------------------
service nginx restart

# config mail posfix
sudo nano /etc/postfix/main.cf
# ----------------------------------------------------------------------
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = static:user-sendgrid:password-sendgrid
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = encrypt
header_size_limit = 4096000
relayhost = [smtp.sendgrid.net]:587
/etc/init.d/postfix restart
# ----------------------------------------------------------------------

# Crontab task
crontab -e
# ----------------------------------------------------------------------
@weekly root /usr/sbin/chkrootkit > /dev/null
@weekly root (/usr/bin/apt-get -f install && sudo /usr/bin/apt-get autoremove && sudo /usr/bin/apt-get -y autoclean && sudo /usr/bin/apt-get -y clean) > /dev/null
@monthly root (/usr/bin/apt-get -y update && /usr/bin/apt-get -y upgrade) > /dev/null
# ----------------------------------------------------------------------

# Clean repositories sources
/etc/apt/sources.list.d

# Clean system
sudo apt-get -f install && sudo apt-get autoremove && sudo apt-get -y autoclean && sudo apt-get -y clean
