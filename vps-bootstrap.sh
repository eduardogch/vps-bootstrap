# update / upgrade
apt-get -y update && apt-get -y upgrade

# install required packages
apt-get install -y build-essential fail2ban ufw nano git git-core curl nginx chkrootkit mailutils libsasl2-modules

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

#config ssh
sudo nano etc/ssh/sshd_config
# ----------------------------------------------------------------------
Port 2936
# ----------------------------------------------------------------------

# config fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
# ----------------------------------------------------------------------
ignoreip = 127.0.0.1/8 your_home_IP
findtime = 3600
maxretry = 6
mta = mail
destemail = email@gmail.com
sendername = Fail2BanAlerts
# ----------------------------------------------------------------------

# Add new eduardo user
adduser eduardo
gpasswd -a eduardo sudo

# View logs
logwatch | less
tail -f /var/log/syslog

# Logwatch
sudo logwatch --mailto email@gmail.com --output mail --format html --range 'between -7 days and today'

# config git
git config --global user.name "Server"
git config --global user.email email@gmail.com

# Install VPN
wget https://raw.github.com/viljoviitanen/setup-simple-pptp-vpn/master/setup.sh
sudo sh setup.sh

# Speedtest
wget -O speedtest-cli https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py
chmod +x speedtest-cli
./speedtest-cli

# Node & Mongo
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get -y update
sudo apt-get -y install nodejs node-gyp
sudo ln -s /usr/bin/nodejs /usr/bin/node
npm install -g npm node-gyp
npm config set strict-ssl false
npm config set registry http://registry.npmjs.org/

# Install MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get -y update && sudo apt-get -y install mongodb-org

### Install Redis
sudo apt-get -y update && sudo apt-get -y install redis-server
sudo update-rc.d redis-server defaults
sudo /etc/init.d/redis-server start

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

# Test email from Postfix
echo "Test mail from postfix" | mail -s "Test Postfix" email@gmail.com

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
