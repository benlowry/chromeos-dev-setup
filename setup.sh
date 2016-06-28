#!/bin/bash

# TODO:
# 1) automate startup of postgresql, c9, pgweb, deluge 
# 2) install dropbox 
# 3) dns server for friendly names on all the other stuff
# 4) music player of some sort
# 5) ssh key generation and outputting the public key after everything
# 6) npm dependencies: jsbeautify, pm2
# 7) heroku toolbelt

# Setting up my chroot
# Open a chrome terminal (ctrl+alt+t)
# Download crouton to ~/Downloads
# Open a terminal ctrl+alt+t
# $ 'shell
# $ sudo sh ~/Downloads/crouton -r trusty -t core
# Once it’s finished setting up
# # sudo enter-chroot
# $ sudo apt-get install -y curl
# $ curl -o- https://raw.githubusercontent.com/benlowry/chromeos-setup/master/setup.sh | bash

sudo apt-get install -y software-properties-common # add-apt-repository
sudo add-apt-repository -y ppa:fkrull/deadsnakes # python 
sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable # golang
sudo add-apt-repository -y ppa:deluge-team/ppa # deluge torrent server
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y libssl-dev build-essential git wget software-properties-common postgresql postgresql-contrib deluge deluge-webui python2.7 golang
mkdir -p ~/gopath && echo “export GOPATH=~/gopath” >> ~/.bash_profile

# Install Deluge (torrent)
sudo adduser —disabled-password —system —home /var/lib/deluge —geeks "Deluge service" —group deluge
sudo touch /var/log/deluged.log
sudo touch /var/log/deluge-web.log
sudo chown deluge:deluge /var/log/deluge*

echo '[Unit]
Description=Deluge Bittorrent Client Daemon
After=network-online.target

[Service]
Type=simple
User=deluge
Group=deluge
UMask=000

ExecStart=/usr/bin/deluged -d

Restart=on-failure

# Configures the time to wait before service is stopped forcefully.
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/deluged.service

echo '[Unit]
Description=Deluge Bittorrent Client Web Interface
After=network-online.target

[Service]
Type=simple

User=deluge
Group=deluge
UMask=027

ExecStart=/usr/bin/deluge-web

Restart=on-failure

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/deluge-web.service

sudo service deluged start
sudo service deluge-web start (doesn’t seem to work)
# start: /usr/bin/deluge-web

# Install NodeJS
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash
~/.nvm/nvm.sh install v6.2.2 (eg)

# Install C9 IDE
git clone git://github.com/c9/core ~/c9
cd ~/c9
./scripts/install-sdk.sh

# Install PGWeb
go get github.com/sosedoff/pgweb
# start:  $GOPATH/bin/pgweb —bind=0.0.0.0 —listen=81
