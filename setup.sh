#!/bin/bash
# This script is public domain.  
{
  C9IO=false
  GITWEBUI=false
  POSTGRES=false
  DELUGE=false
  C9=false
  PGWEB=false
  DROPBOX=false
  PLEX=false
  
  if [ -z $C9_PORT ]; then
    C9_PORT=8080
  fi
  if [ -z $GITWEBUI_PORT ]; then
    GITWEBUI_PORT=8081
  fi
  if [ -z $PGWEB_PORT ]; then
    PGWEB_PORT=8082
  fi
  if [ -z $DELUGE_PORT ]; then
    DELUGE_PORT=8083
  fi
  
  if [ ! -z $C9_SHARED ]; then
    C9IO=true
  fi
    
  # General dependencies
  if [ -z `command -v add-apt-repository` ] || [ ! $C9IO = "true" ]; then 
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y libssl-dev build-essential software-properties-common openssh-client man
    # TODO: per-package checks/installs  
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
    cd ~/
    git clone https://github.com/alberthier/git-webui.git
    git config --global alias.webui \!$PWD/git-webui/release/libexec/git-core/git-webui
    GITWEBUI=true
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
     if [ $C9IO = "false" ]; then
      git clone https://github.com/creationix/nvm.git ~/.nvm
      cd ~/.nvm
      git checkout `git describe --abbrev=0 --tags`
      . ~/.nvm/nvm.sh
      echo "export NVM_DIR=$HOME/.nvm" >> ~/.bash_profile
      echo "[ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh" >> ~/.bash_profile
      source ~/.bash_profile
    fi
    nvm install node
    nvm alias default node
  fi
    
  # PostgreSQL, preinstalled on c9.io
   if [[ $@ == *"postgres"* ]] || [ -z $@ ]; then
     if [ ! $C9IO = "true" ]; then
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
        wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
        sudo apt-get install -y postgresql postgresql-contrib
        sudo echo "service postgresql start" >> /etc/rc.local
    fi
    sudo service postgresql start
    POSTGRES=true
  fi
  
  # Install Deluge (torrent), disabled on c9.io
   if [ ! $C9IO = "true" ] && ([[ $@ == *"deluge"* ]] || [ -z $@ ]); then
    sudo apt-get install -y deluge deluge-web deluged
    DELUGE=true
    # start: deluge -u web
  fi
  
  # Install C9 IDE, preinstalled on c9.io 
   if [ ! $C9IO = "true" ] && ([[ $@ == *"c9"* ]] || [ -z $@ ]); then
    git clone git://github.com/c9/core ~/c9
    cd ~/c9/scripts
    ./install-sdk.sh
    cd ~/
    echo "node c9/server.js -w ~/projects --listen 0.0.0.0 --port=$C9_PORT > /dev/null" >> ~/.bash_profile
    C9=true
  fi
  
  # Install PGWeb
   if [[ $@ == *"pgweb"* ]] || [ -z $@ ]; then
    curl -O -L https://github.com/sosedoff/pgweb/releases/download/v0.9.3/pgweb_linux_amd64.zip
    unzip pgweb_linux_amd64.zip
    mv pgweb_linux_amd64 /usr/bin/pgweb
    rm -rf pgweb_linux_amd64.zip
    if [ -z `command -v pm2` ]; then
      echo "pgweb --bind=0.0.0.0 --listen=$PGWEB_PORT > /dev/null &" >> ~/.bash_profile
    fi
    PGWEB=true
  fi

  # Dropbox
   if [[ $@ == *"dropbox"* ]] || [ -z $@ ]; then
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    DROPBOX=true
    # start: ~/.dropbox-dist/dropboxd
  fi
  
  # Emby
  if [ ! $C9IO = "true" ] && ([[ $@ == *"emby"* ]] || [ -z $@ ]); then
    sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/emby/xUbuntu_14.04/ /' >> /etc/apt/sources.list.d/emby-server.list"
    sudo apt-get update
    sudo apt-get install -y --force-yes emby-server
    EMBY=true
    # TODO: is it weird this requires force-yes and installs a bunch of certificates?
    # start: sudo /usr/bin/emby-server start
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
  echo 'SSH KEY starts on the line below:'
  echo $SSHKEY
  
  # startup notes and setup completion notes
  if [ $C9 = "true" ] && [ $C9IO = "false" ]; then
    echo '----------------------------------------'
    echo 'C9 browser IDE can be started with:'
    echo '$ node server.js -w ~/yourproject --listen 0.0.0.0 --port=${C9_PORT}'
    echo 'Open in your browser at http://127.0.0.1:${C9_PORT}/'
  fi
  
  if [ $POSTGRES = "true" ]; then
    echo '----------------------------------------'
    echo 'PostgreSQL can be started with:'
    echo '$ sudo service postgresql start'
  fi
  
  if [ $PGWEB = "true" ]; then
    echo '----------------------------------------'
    echo 'PGWeb interface for PostgreSQL can be started with:'
    echo '$ pgweb --bind 0.0.0.0 --listen=${PGWEB_PORT}'
    echo 'Open in your browser at http://127.0.0.1:${PGWEB_PORT}/'
  fi
  
  if [ $DELUGE = "true" ]; then
    echo '----------------------------------------'
    echo 'Deluge torrent server and web interface can be started with:'
    echo '$ deluge-web -p ${DELUGE_PORT}'
    echo '$ deluge -u web'
    echo 'Open in your browser at http://127.0.0.1:${DELUGE_PORT}/'
  fi
   
  if [ $GITWEBUI = "true" ]; then
    echo '----------------------------------------'
    echo 'Git WebUI can be started from your project directory with:'
    echo '$ git webui --host 0.0.0.0 --no-browser --port ${GITWEBUI_PORT}'
    echo 'Open in your browser at http://127.0.0.1:${GITWEBUI_PORT}/'
  fi
  
  if [ $DROPBOX = "true" ]; then
    echo '----------------------------------------'
    echo 'Dropbox setup can be completed by:'
    echo '$ ~/.dropbox-dist/dropboxd'
  fi
  
  if [ $EMBY = "true" ]; then
    echo '----------------------------------------'
    echo 'Emby can be started by:'
    echo '$ sudo /usr/bin/emby-server start'
    echo 'Open in your browser at http://127.0.0.1:8096/'
  fi
}
