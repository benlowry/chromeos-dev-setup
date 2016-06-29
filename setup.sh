#!/bin/bash
{
  if [ -z $EMAIL ]; then
    read -p "Enter your email for git commits: " EMAIL
  fi
  
  if [ -z $NAME ]; then
    read -p "Enter your name for git commits: " NAME
  fi
  
  sudo apt-get update && sudo apt-get upgrade
  sudo apt-get install -y libssl-dev build-essential git software-properties-common openssh-client
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL"
  
  # Python
  sudo add-apt-repository -y ppa:fkrull/deadsnakes
  sudo apt-get install -y python2.7
  
  # Golang
  sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
  mkdir -p ~/gopath
  echo "export GOPATH=~/gopath" >> ~/.bash_profile
  source ~/.bash_profile
  
  # NodeJS
  git clone https://github.com/creationix/nvm.git ~/.nvm
  cd ~/.nvm
  git checkout `git describe --abbrev=0 --tags`
  . ~/.nvm/nvm.sh
  echo "export NVM_DIR=$HOME/.nvm" >> ~/.bash_profile
  echo "[ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh" >> ~/.bash_profile
  source ~/.bash_profile
  nvm install node
  
  # PostgreSQL
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  sudo apt-get install -y postgresql postgresql-contrib
  
  # Install Deluge (torrent)
  sudo add-apt-repository -y ppa:deluge-team/ppa
  sudo apt-get install -y deluge deluge-webui
  sudo adduser --disabled-password --system --home /var/lib/deluge --geeks "Deluge service" --group deluge
  sudo touch /var/log/deluged.log
  sudo touch /var/log/deluge-web.log
  sudo chown deluge:deluge /var/log/deluge*
  
  curl -o /etc/systemd/system/deluged.service https://raw.githubusercontent.com/benlowry/chromeos-setup/master/deluged.service
  curl -o /etc/systemd/system/deluged-web.service https://raw.githubusercontent.com/benlowry/chromeos-setup/master/deluged-web.service
  sudo service deluged start
  # sudo service deluge-web start 
  # start: /usr/bin/deluge-web
  
  # Install C9 IDE
  git clone git://github.com/c9/core ~/c9
  cd ~/c9/scripts
  ./install-sdk.sh
  cd ~/
  # start: node server.js -w ~/projectfolder --listen 0.0.0.0 --port=81
  
  # Install PGWeb
  go get github.com/sosedoff/pgweb
  # start:  $GOPATH/bin/pgweb —bind=0.0.0.0 —listen=82

  # Dropbox
  cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
  # start: ~/.dropbox-dist/dropboxd

  # SSH key
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  touch ~/.ssh/authorized_keys
  chmod 644 ~/.ssh/authorized_keys
  chown $USER:$USER ~/.ssh/authorized_keys
  chown $USER:$USER ~/.ssh
  ssh-keygen -t rsa -b 4096 -C "$EMAIL"  -f ~/.ssh/id_rsa -N ''
  chmod 600 ~/.ssh/id_rsa
  echo '-------------- setup complete --------------'
  echo 'next line is your new public key for github etc'
  cat ~/.ssh/id_rsa.pub
}
