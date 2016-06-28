#!/bin/bash
{
  sudo apt-get install -y libssl-dev build-essential git software-properties-common openssh-client
  sudo add-apt-repository -y ppa:fkrull/deadsnakes
  sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable 
  sudo add-apt-repository -y ppa:deluge-team/ppa
  sudo apt-get update 
  sudo apt-get upgrade -y
  sudo apt-get install -y postgresql postgresql-contrib deluge deluge-webui python2.7 golang
  mkdir -p ~/gopath
  echo "export GOPATH=~/gopath" >> ~/.bash_profile
  source ~/.bash_profile
  
  # Install Deluge (torrent)
  sudo adduser —disabled-password —system —home /var/lib/deluge —geeks "Deluge service" —group deluge
  sudo touch /var/log/deluged.log
  sudo touch /var/log/deluge-web.log
  sudo chown deluge:deluge /var/log/deluge*
  
  curl -o /etc/systemd/system/deluged.service https://raw.githubusercontent.com/benlowry/chromeos-setup/master/deluged.service
  curl -o /etc/systemd/system/deluged-web.service https://raw.githubusercontent.com/benlowry/chromeos-setup/master/deluged-web.service
  sudo service deluged start
  # sudo service deluge-web start 
  # start: /usr/bin/deluge-web
  
  # Install NodeJS
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash
  source ~/.bashrc
  nvm install v6.2.2
  npm install -g pm2 jsbeautify dotenv
  
  # Install C9 IDE
  git clone git://github.com/c9/core ~/c9
  cd ~/c9/scripts
  ./install-sdk.sh
  cd ~/
  
  # Install PGWeb
  go get github.com/sosedoff/pgweb
  # start:  $GOPATH/bin/pgweb —bind=0.0.0.0 —listen=81

  # Dropbox
  cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
  # start: ~/.dropbox-dist/dropboxd

  # SSH key has to go last so we can access the private key more easily
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  touch ~/.ssh/authorized_keys
  chmod 644 ~/.ssh/authorized_keys
  chown $USER:$USER ~/.ssh/authorized_keys
  chown $USER:$USER ~/.ssh
  ssh-keygen -t rsa -b 4096 -C "$EMAIL"  -f id_rsa -N ''
  chmod 600 ~/.ssh/id_rsa
  echo '-------------- setup complete --------------'
  echo 'running dropbox daemon now to create url for linking this device'
  ~/.dropbox-dist/dropboxd
  
  echo 'next line is your new public key for github etc'
  cat ~/.ssh/id_rsa.pub
}
