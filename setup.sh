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
  if [ ! -z $python ] || [ -z $@ ]; then
    sudo add-apt-repository -y ppa:fkrull/deadsnakes
    sudo apt-get install -y python2.7
  fi
  
  # Golang
  if [ ! -z $golang ]; then
    sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
    sudo apt-get install -y golang
    mkdir -p ~/gopath
    echo "export GOPATH=~/gopath" >> ~/.bash_profile
    source ~/.bash_profile
  fi
    
  # NodeJS
  if [ ! -z $nodejs ]; then
    git clone https://github.com/creationix/nvm.git ~/.nvm
    cd ~/.nvm
    git checkout `git describe --abbrev=0 --tags`
    . ~/.nvm/nvm.sh
    echo "export NVM_DIR=$HOME/.nvm" >> ~/.bash_profile
    echo "[ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh" >> ~/.bash_profile
    source ~/.bash_profile
    nvm install node
  fi
    
  # PostgreSQL
  if [ ! -z $postgres ] || [ ! -z $postgresql ]; then
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
    wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
    sudo apt-get install -y postgresql postgresql-contrib
  fi
  
  # Install Deluge (torrent)
  if [ ! -z $deluge ]; then
    sudo add-apt-repository -y ppa:deluge-team/ppa
    sudo apt-get install -y deluge deluge-webui
    sudo adduser --disabled-password --system --home /var/lib/deluge --geeks "Deluge service" --group deluge
    sudo touch /var/log/deluged.log
    sudo touch /var/log/deluge-web.log
    sudo chown deluge:deluge /var/log/deluge*
    sudo curl -o /etc/systemd/system/deluged.service https://raw.githubusercontent.com/benlowry/chromeos-setup/master/deluged.service
    sudo curl -o /etc/systemd/system/deluge-web.service https://raw.githubusercontent.com/benlowry/chromeos-setup/master/deluge-web.service
    sudo service deluged start
    # sudo service deluge-web start 
    # start: /usr/bin/deluge-web
  fi
  
  # Install C9 IDE
  if [ !-z $c9 ]; then
    git clone git://github.com/c9/core ~/c9
    cd ~/c9/scripts
    ./install-sdk.sh
    cd ~/
    # start: node server.js -w ~/projectfolder --listen 0.0.0.0 --port=81
  fi
  
  # Install PGWeb
  if [ ! -z $pgweb ]; then
    go get github.com/sosedoff/pgweb
    # start:  $GOPATH/bin/pgweb —bind=0.0.0.0 —listen=82
  fi

  # Dropbox
  if [ ! -z $dropbox ]; then
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    # start: ~/.dropbox-dist/dropboxd
  fi

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
