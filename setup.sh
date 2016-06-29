#!/bin/bash
{
  # General dependencies
  if [ -z `command -v add-apt-repository` ]; then 
    sudo apt-get update && sudo apt-get upgrade
    sudo apt-get install -y libssl-dev build-essential software-properties-common openssh-client man
  fi
  
  # Git 
  if [ -z `command -v git` ]; then
    if [ -z $EMAIL ]; then
      read -p "Enter your email for git commits: " EMAIL
    fi
    
    if [ -z $NAME ]; then
      read -p "Enter your name for git commits: " NAME
    fi
    sudo apt-get install -y git
    git config --global user.name "$NAME"
    git config --global user.email "$EMAIL"
  fi
  
  # Git-WebUI
  if [[ $@ == *"git-webui"* ]] || [ -z $@ ]; then
    git clone https://github.com/alberthier/git-webui.git
    git config --global alias.webui \!$PWD/git-webui/release/libexec/git-core/git-webui
  fi

  # Python
   if [[ $@ == *"python"* ]] || [ -z $@ ]; then
    sudo add-apt-repository -y ppa:fkrull/deadsnakes
    sudo apt-get install -y python2.7
  fi
  
  # Golang
   if [[ $@ == *"golang"* ]] || [ -z $@ ]; then
    sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
    sudo apt-get install -y golang
    mkdir -p ~/gopath
    echo "export GOPATH=~/gopath" >> ~/.bash_profile
    source ~/.bash_profile
  fi
    
  # NodeJS
   if [[ $@ == *"nodejs"* ]] || [ -z $@ ]; then
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
   if [[ $@ == *"postgres"* ]] || [ -z $@ ]; then
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
    wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
    sudo apt-get install -y postgresql postgresql-contrib
  fi
  
  # Install Deluge (torrent)
   if [[ $@ == *"deluge"* ]] || [ -z $@ ]; then
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
   if [[ $@ == *"c9"* ]] || [ -z $@ ]; then
    git clone git://github.com/c9/core ~/c9
    cd ~/c9/scripts
    ./install-sdk.sh
    cd ~/
    # start: node server.js -w ~/projectfolder --listen 0.0.0.0 --port=81
  fi
  
  # Install PGWeb
   if [[ $@ == *"pgweb"* ]] || [ -z $@ ]; then
    go get github.com/sosedoff/pgweb
    # start:  $GOPATH/bin/pgweb —bind=0.0.0.0 —listen=82
  fi

  # Dropbox
   if [[ $@ == *"dropbox"* ]] || [ -z $@ ]; then
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    # start: ~/.dropbox-dist/dropboxd
  fi

  # SSH key
  if [ ! -f ~/.ssh/id_rsa ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    touch ~/.ssh/authorized_keys
    chmod 644 ~/.ssh/authorized_keys
    chown $USER:$USER ~/.ssh/authorized_keys
    chown $USER:$USER ~/.ssh
    ssh-keygen -t rsa -b 4096 -C "$EMAIL"  -f ~/.ssh/id_rsa -N ''
    chmod 600 ~/.ssh/id_rsa*
  fi
  
  SSHKEY=`cat ~/.ssh/id_rsa.pub`
  
  echo '----------------------------------------'
  echo 'Setup complete'
  echo '----------------------------------------'
  echo 'SSH KEY:'
  echo $SSHKEY
  
  # startup notes and setup completion notes
  if [[ $@ == *"git-webui"* ]] || [ -z $@ ]; then
    echo '----------------------------------------'
    echo 'Git WebUI can be started from your project directory with `git webui`'
  fi
  
}
