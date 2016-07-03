#!/bin/bash
# This script is public domain.  
{
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
    DELUGE_PORT=8112
  fi
  
  if [ ! -z $C9_SHARED ]; then
    C9IO=true
  fi
  
  if [ -z `command -v git` ]; then
    # Get this now because nothing else requires input
    if [ -z $EMAIL ]; then
      read -p "Enter your email for git commits: " EMAIL
    fi
    if [ -z $NAME ]; then
      read -p "Enter your name for git commits: " NAME
    fi
  fi
  
  ALL=true
  for f in git-webui python golang nodejs postgres deluge c9 pgweb dropbox emby heroku awscli s3cmd doctld; do
    if [[ ! "$@" == *"-$f"* ]] &&  [[ "$@" == *"$f"* ]]; then
      ALL=false
      break
    fi
  done
    
  # package dependencies
  PKG=""
  for f in libssl-dev build-essential software-properties-common openssh-client man unzip git; do
    INSTALLED=`dpkg-query -l $f | grep Version`
    if [ -z "$INSTALLED" ]; then
      PKG="$PKG $f"
    fi
  done
  
  if [ ! -z $PKG ]; then
    echo "Installing $PKG"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y "$PKG"
  fi
  
  if [ ! -z "$NAME" ]; then
    git config --global user.name "$NAME"
  fi
  if [ ! -z "$EMAIL" ]; then
    git config --global user.email "$EMAIL"
  fi
  
  # Git-WebUI
  if [[ ! "$@" == *"-git-webui"* ]] && ([[ "$@" == *"git-webui"* ]] || [ $ALL = "true" ]); then
    cd $HOME
    git clone https://github.com/alberthier/git-webui.git
    git config --global alias.webui \!$PWD/git-webui/release/libexec/git-core/git-webui
    GITWEBUI=true
  fi

  # Python
   if [[ ! "$@" == *"-python"* ]] && ([[ "$@" == *"python"* ]] || [ $ALL = "true" ]); then
    sudo add-apt-repository -y ppa:fkrull/deadsnakes
    sudo apt-get update 
    sudo apt-get install -y python2.7
  fi
  
  # Golang
   if [[ ! "$@" == *"-golang"* ]] && ([[ "$@" == *"golang"* ]] || [ $ALL = "true" ]); then
    sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
    sudo apt-get update 
    sudo apt-get install -y golang
    mkdir -p $HOME/gopath
    echo "export GOPATH=$HOME/gopath" >> $HOME/.bash_profile
    source $HOME/.bash_profile
  fi
    
  # NodeJS
   if [[ ! "$@" == *"-nodejs"* ]] && ([[ "$@" == *"nodejs"* ]] || [ $ALL = "true" ]); then
     if [ ! "$C9IO" = "true" ]; then
      git clone https://github.com/creationix/nvm.git $HOME/.nvm
      cd $HOME/.nvm
      git checkout `git describe --abbrev=0 --tags`
      . $HOME/.nvm/nvm.sh
      echo "export NVM_DIR=$HOME/.nvm" >> $HOME/.bash_profile
      echo "[ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh" >> $HOME/.bash_profile
      source $HOME/.bash_profile
    fi
    nvm install node
    nvm alias default node
  fi
    
  # PostgreSQL, preinstalled on c9.io
   if [[ ! "$@" == *"-postgres"* ]] && ([[ "$@" == *"postgres"* ]] || [ $ALL = "true" ]); then
     if [ ! "$C9IO" = "true" ]; then
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
        wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
        sudo apt-get update 
        sudo apt-get install -y postgresql postgresql-contrib libpq-dev
    fi
    sudo service postgresql start
    POSTGRES=true
  fi
  
  # Install Deluge (torrent), disabled on c9.io
   if [[ ! "$@" == *"-deluge"* ]] && ([ ! "$C9IO" = "true" ] && ([[ "$@" == *"deluge"* ]] || [ $ALL = "true" ])); then
    sudo apt-get install -y deluge deluge-web deluged
    echo "if [ \"`pwd`\" = \"$HOME\" ]; then
            sudo /usr/bin/deluge-web --no-ssl -p $DELUGE_PORT > /dev/null &
          fi" >> $HOME/.bash_profile
    DELUGE=true
    # start: deluge -u web
  fi
  
  # Install Cloud9 IDE, preinstalled on c9.io 
   if [[ ! "$@" == *"-c9"* ]] && ([ ! "$C9IO" = "true" ] && ([[ "$@" == *"c9"* ]] || [ $ALL = "true" ])); then
    git clone git://github.com/c9/core $HOME/c9
    cd $HOME/c9/scripts
    ./install-sdk.sh
    cd $HOME/
    npm install -g pm2
    echo "if [ \"`pwd`\" = \"$HOME\" ]; then
            pm2 start c9/server.js --error /dev/null --output /dev/null --name cloud9 -- -w projects --port=$C9_PORT 
          fi" >> $HOME/.bash_profile
    C9=true
  fi
  
  # Install PGWeb
   if [[ ! "$@" == *"-pgweb"* ]] && ([[ "$@" == *"pgweb"* ]] || [ $ALL = "true" ]); then
    curl -O -L https://github.com/sosedoff/pgweb/releases/download/v0.9.3/pgweb_linux_amd64.zip
    unzip pgweb_linux_amd64.zip
    sudo mv pgweb_linux_amd64 /usr/bin/pgweb
    rm -rf pgweb_linux_amd64.zip
    echo "if [ \"`pwd`\" = \"$HOME\" ]; then
            RUNNING=`ps cax | grep pgweb`
            if [ ! z $RUNNING ]; then 
              pgweb --bind=0.0.0.0 --listen=${PGWEB_PORT} > /dev/null & 
            fi
          fi" >> $HOME/.bash_profile
    PGWEB=true
  fi

  # Dropbox
   if [[ ! "$@" == *"-dropbox"* ]] && ([[ "$@" == *"dropbox"* ]] || [ $ALL = "true" ]); then
    cd $HOME && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    # cli tool
    wget -O $HOME/dropbox.py "http://www.dropbox.com/download?dl=packages/dropbox.py"
    chmod 755 dropbox.py 
    echo "if [ \"`pwd`\" = \"$HOME\" ]; then
            ~/dropbox.py start
          fi" >> $HOME/.bash_profile
    DROPBOX=true
    # start: $HOME/.dropbox-dist/dropboxd
  fi
  
  # Emby
  if [[ ! "$@" == *"-emby"* ]] && ([ ! "$C9IO" = "true" ] && ([[ "$@" == *"emby"* ]] || [ $ALL = "true" ])); then
    sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/emby/xUbuntu_14.04/ /' >> /etc/apt/sources.list.d/emby-server.list"
    sudo apt-get update
    sudo apt-get install -y --force-yes emby-server
    echo "RUNNING=`ps cax | grep emby`
          if [ -z $RUNNING ]; then
            sudo /etc/init.d/emby-server restart
          fi" >> $HOME/.bash_profile
    EMBY=true
    # TODO: is it weird this requires force-yes and installs a bunch of certificates?
    # start: sudo /usr/bin/emby-server start
  fi
  
  # Heroku
  if [[ ! "$@" == *"-heroku"* ]] && ([[ "$@" == *"heroku"* ]] || [ $ALL = "true" ]); then
    wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
    HEROKU=true
  fi
  
  # AWS CLI
  if [[ ! "$@" == *"-awscli"* ]] && ([[ "$@" == *"awscli"* ]] || [ $ALL = "true" ]); then
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -b $HOME/.awscli
    rm -rf awscli-bundle.zip
    AWSCLI=true
  fi
  
  # S3CMD
  if [[ ! "$@" == *"-s3cmd"* ]] && ([[ "$@" == *"s3cmd"* ]] || [ $ALL = "true" ]); then
    wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add -
    sudo wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list
    sudo apt-get install -y s3cmd
    S3CMD=true
  fi
  
  # Digital Ocean CLI
  if [[ ! "$@" == *"-doctl"* ]] && ([[ "$@" == *"doctl" ]] || [ $ALL = "true" ]); then
    curl -OL https://github.com/digitalocean/doctl/releases/download/v1.0.0/doctl-1.0.0-linux-amd64.tar.gz
    tar xf doctl-1.0.0-linux-amd64.tar.gz
    sudo mv ./doctl /usr/local/bin
    rm -rf doctl-1.0.0-linux-amd64.tar.gz
    DOCTL=true
  fi
  
  # SSH key
  if [ ! -f $HOME/.ssh/id_rsa ]; then
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh
    touch $HOME/.ssh/authorized_keys
    chmod 644 $HOME/.ssh/authorized_keys
    chown $USER:$USER $HOME/.ssh/authorized_keys
    chown $USER:$USER $HOME/.ssh
    ssh-keygen -t rsa -b 4096 -C "$EMAIL"  -f $HOME/.ssh/id_rsa -N ""
    chmod 600 $HOME/.ssh/id_rsa*
  fi
  
  cd ~/
  source $HOME/.bash_profile
  
  echo "--------------------------------------------"
  echo "Setup complete"
  
  # startup notes and setup completion notes
  if [ "$C9" == "true" ] && [ ! "$C9IO" = "true" ]; then
    echo "--------------------------------------------"
    echo "C9 browser IDE can be opened in your browser at:"
    echo "http://127.0.0.1:${C9_PORT}/"
  fi
  
  if [ "$POSTGRES" = "true" ]; then
    echo "-------------------------------------------"
    echo "PostgreSQL is running on port 5432 and"
    echo "waiting for you to create a database:"
    echo " $ sudo -i -u postgres"
    echo " $ createuser -P -s -e mydb"
    echo " $ createdb mydb --owner mydb"
  fi
  
  if [ "$PGWEB" = "true" ]; then
    echo "--------------------------------------------"
    echo "PGWeb can be opened in your browser at:"
    echo "http://127.0.0.1:${PGWEB_PORT}/"
  fi
  
  if [ "$DELUGE" = "true" ]; then
    echo "--------------------------------------------"
    echo "Deluge can be opened in your browser at:"
    echo " http://127.0.0.1:${DELUGE_PORT}/ pwd 'deluge'"
  fi
   
  if [ "$GITWEBUI" = "true" ]; then
    echo "--------------------------------------------"
    echo "Git WebUI can be started in a repo:"
    echo " $ git webui --host 0.0.0.0 --no-browser --port ${GITWEBUI_PORT}"
    echo ""
    echo "Git WebUI can be opened in your browser at:"
    echo " http://127.0.0.1:${GITWEBUI_PORT}/"
  fi
  
  if [ "$DROPBOX" = "true" ]; then
    echo "--------------------------------------------"
    echo "Dropbox setup can be completed by:"
    echo " $ $HOME/.dropbox-dist/dropboxd"
    echo " $ ~/dropbox.py autostart"
    echo ""
    echo "Exclude folders with selective sync:"
    echo " $ ~/dropbox.py exclude add a_folder"
    echo ""
    echo "Exclude all folders except 'chromedev':"
    echo " $ cd ~/Dropbox && for x in *; do if [ ! \"$x\" = \"chromedev\" ]; then ~/dropbox.py exclude add \"$x\"; fi done;\""
    echo ""
    echo "Replace ~/projects with ~/Dropbox/chromedev:"
    echo " $ rm -rf ~/projects && ln -s ~/Dropbox/chromedev ~/projects"
  fi
  
  if [ "$EMBY" = "true" ]; then
    echo "--------------------------------------------"
    echo "Emby can be opened in your browser at:"
    echo " http://127.0.0.1:8096/"
  fi
  
  if [ "$HEROKU" = "true" ]; then
    echo "--------------------------------------------"
    echo "Heroku is installed but requires:"
    echo " $ heroku login"
  fi
  
  if [ "$AWSCLI" = "true" ]; then
    echo "--------------------------------------------"
    echo "AWS CLI is installed"
  fi
  
  if [ "$S3CMD" = "true" ]; then
    echo "--------------------------------------------"
    echo "S3CMD is installed"
  fi
  
  if [ "$DOCTL" = "true" ]; then
    echo "--------------------------------------------"
    echo "DOCTL is installed"
  fi
  
  echo "--------------------------------------------"
  echo "This is your new SSH key:"
  echo ""
  echo "`cat $HOME/.ssh/id_rsa.pub`"
}
