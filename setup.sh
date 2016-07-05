#!/bin/bash
# This script is public domain.  
{
  # ------------------------------------------------
  # override the default ports, selected to align 
  # with c9.io exposed public ports
  # ------------------------------------------------
  # note: emby port can't be changed during install
  if [ -z $C9_PORT ]; then
    C9_PORT=8080 # default 
  fi
  
  if [ -z $PGWEB_PORT ]; then
    PGWEB_PORT=8081 # default
  fi
  
  if [ -z $GITWEBUI_PORT ]; then
    GITWEBUI_PORT=8082 # default 8000
  fi
  
  if [ -z $REDIS_COMMANDER_PORT ]; then
    $REDIS_COMMANDER_PORT=8083 # default 8081
  fi
  
  if [ -z $DELUGE_PORT ]; then
    DELUGE_PORT=8112 # default
  fi
  
  if [ ! -z $C9_SHARED ]; then
    C9IO=true
  fi
  
  # get git signatures now because nothing else needs input
  # unless sudo times out
  if [ -z `command -v git` ]; then
    if [ -z $EMAIL ]; then
      read -p "Enter your email for git commits: " EMAIL
    fi
    if [ -z $NAME ]; then
      read -p "Enter your name for git commits: " NAME
    fi
  fi
  
  # check if we're installing all packages
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
    if [ "$f" = "unzip" ] || [ "$f" = "man" ] || [ "$f" = "git" ]; then
        if hash gdate 2>/dev/null; then
           continue
        fi
        PKG="$PKG $f"
        continue
    fi  
    INSTALLED=`dpkg-query -l $f | grep Version`
    if [ -z "$INSTALLED" ]; then
      PKG="$PKG $f"
    fi
  done
  
  # install missing packages
  if [ ! -z "$PKG" ]; then
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y $PKG
  fi
  
  # configure git
  if [ ! -z "$NAME" ]; then
    git config --global user.name "$NAME"
  fi
  if [ ! -z "$EMAIL" ]; then
    git config --global user.email "$EMAIL"
  fi

  # ------------------------------------------------
  # LANGUAGES alphabetically
  # ------------------------------------------------
  # Pull requests welcome
  echo 'PWD=\`pwd\`' >> $HOME/.bash_profile
  
  # Golang
  if [[ ! "$@" == *"-golang"* ]] && ([[ "$@" == *"golang"* ]] || [ $ALL = "true" ]); then
    sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
    sudo apt-get update 
    sudo apt-get install -y golang
    mkdir -p $HOME/gopath
    echo "export GOPATH=$HOME/gopath" >> $HOME/.bash_profile
    GOLANG=true
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
    fi
    . $HOME/.nvm/nvm.sh
    nvm install node
    nvm alias default node
    NODEJS=true
  fi
  
  # Python
  if [[ ! "$@" == *"-python"* ]] && ([[ "$@" == *"python"* ]] || [ $ALL = "true" ]); then
    sudo add-apt-repository -y ppa:fkrull/deadsnakes
    sudo apt-get update 
    sudo apt-get install -y python2.7
    PYTHON=true
  fi
    
  # ------------------------------------------------  
  # WEB SERVERS alphabetically
  # ------------------------------------------------
  # Pull requests welcome please check c9.io's 
  # policies and keep the script compliant by default
  
  # Cloud9 IDE, skipped on c9.io
   if [[ ! "$@" == *"-c9"* ]] && ([ ! "$C9IO" = "true" ] && ([[ "$@" == *"c9"* ]] || [ $ALL = "true" ])); then
    git clone git://github.com/c9/core $HOME/c9
    cd $HOME/c9/scripts
    ./install-sdk.sh
    cd $HOME/
    npm install -g pm2
    echo "if [ \"\$PWD\" = \"\$HOME\" ]; then
            RUNNING=\`pm2 list | grep -i cloud9\`
            if [ -z "$RUNNING" ]; then
              pm2 start c9/server.js --error /dev/null --output /dev/null --name cloud9 -- -w projects --port=$C9_PORT 
            fi
          fi" >> $HOME/.bash_profile
    CLOUD9=true
  fi
  
  # Deluge, skipped on c9.io
   if [[ ! "$@" == *"-deluge"* ]] && ([ ! "$C9IO" = "true" ] && ([[ "$@" == *"deluge"* ]] || [ $ALL = "true" ])); then
    sudo apt-get install -y deluge deluge-web deluged
    echo "if [ \"\$PWD\" = \"\$HOME\" ]; then
            sudo /usr/bin/deluge-web --no-ssl -p $DELUGE_PORT > /dev/null &
          fi" >> $HOME/.bash_profile
    DELUGE=true
    # start: deluge -u web
  fi
  
  # Emby, skipped on c9.io
  if [[ ! "$@" == *"-emby"* ]] && ([ ! "$C9IO" = "true" ] && ([[ "$@" == *"emby"* ]] || [ $ALL = "true" ])); then
    sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/emby/xUbuntu_14.04/ /' >> /etc/apt/sources.list.d/emby-server.list"
    sudo apt-get update
    sudo apt-get install -y --force-yes emby-server
    echo "if [ \"\$PWD\" = \"\$HOME\" ]; then
            RUNNING=\`ps -ax | grep -i emby\`
            if [ -z \"\$RUNNING\" ]; then
              sudo /etc/init.d/emby-server start
            fi
          fi" >> $HOME/.bash_profile
    EMBY=true
    # start: sudo /usr/bin/emby-server start
  fi
  
  # Git-WebUI
  if [[ ! "$@" == *"-git-webui"* ]] && ([[ "$@" == *"git-webui"* ]] || [ $ALL = "true" ]); then
    cd $HOME
    git clone https://github.com/alberthier/git-webui.git
    git config --global alias.webui \!$PWD/git-webui/release/libexec/git-core/git-webui
    GITWEBUI=true
  fi
  
  # PGWeb
   if [[ ! "$@" == *"-pgweb"* ]] && ([[ "$@" == *"pgweb"* ]] || [ $ALL = "true" ]); then
    curl -O -L https://github.com/sosedoff/pgweb/releases/download/v0.9.3/pgweb_linux_amd64.zip
    unzip pgweb_linux_amd64.zip
    sudo mv pgweb_linux_amd64 /usr/bin/pgweb
    rm -rf pgweb_linux_amd64.zip
    echo "if [ \"\$PWD\" = \"\$HOME\" ]; then
            RUNNING=\`ps -ax | grep -i pgweb\`
            if [ -z \"\$RUNNING\" ]; then 
              pgweb --bind=0.0.0.0 --listen=$PGWEB_PORT > /dev/null & 
            fi
          fi" >> $HOME/.bash_profile
    PGWEB=true
  fi
  
  # redis-commander
  if [[ ! "$@" == *"-redis-commander"* ]] && ([[ "$@" == *"redis-commander"* ]] || [ $ALL = "true" ]); then
   # TODO: there is a bug preventing redis-commander using current node
    nvm install v4.0.0 && nvm use v4.0.0
    npm install -g pm2 
    echo "if [ \"\$PWD\" = \"\$HOME\" ]; then
            RUNNING=`ps -ax | grep -i pm2`
            if [ ! -z \"\$RUNNING\" ]; then
              RUNNING=`pm2 list | grep redis-commander`
            fi
            if [ -z \"\$RUNNING\" ]; then
              pm2 start redis-commander --error /dev/null --output /dev/null --name redis-commander -- --port=$REDIS_COMMANDER_PORT
            fi
          fi" >> $HOME/.bash_profile
    REDIS_COMMANDER=true
    nvm use default
  fi
  
  # ------------------------------------------------
  # TOOLS alphabetically
  # ------------------------------------------------
  # Pull requests welcome with your prefered db etc
  
  # Dropbox
  if [[ ! "$@" == *"-dropbox"* ]] && ([[ "$@" == *"dropbox"* ]] || [ $ALL = "true" ]); then
    cd $HOME && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    # cli tool
    wget -O $HOME/dropbox.py "http://www.dropbox.com/download?dl=packages/dropbox.py"
    chmod 755 dropbox.py 
    echo "if [ \"\$PWD\" = \"\$HOME\" ]; then
            RUNNING=\`ps -ax | grep -i dropbox\`
            if [ -z \"\$RUNNING\" ]; then 
              ~/dropbox.py start
            fi
          fi" >> $HOME/.bash_profile
    DROPBOX=true
    # start: $HOME/.dropbox-dist/dropboxd
  fi
  
  # Redis, only available internally on c9.io
  if [[ ! "$@" == "*-redis"* ]] && ([[ "$@" == *"redis"* ]] || [ $ALL = "true" ]); then 
    sudo apt-get install -y tcl8.5
    wget http://download.redis.io/releases/redis-stable.tar.gz
    tar xzf redis-stable.tar.gz
    cd redis-stable
    make
    sudo make install
    cd ~/
    REDIS=true
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
    POSTGRESQL=true
  fi
  
  # ------------------------------------------------
  # HOSTING services alphabetically
  # ------------------------------------------------
  # Pull requests welcome
  
  # AWS CLI
  if [[ ! "$@" == *"-awscli"* ]] && ([[ "$@" == *"awscli"* ]] || [ $ALL = "true" ]); then
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -b $HOME/.awscli
    rm -rf awscli-bundle.zip
    AWSCLI=true
  fi
  
  # Digital Ocean CLI
  if [[ ! "$@" == *"-doctl"* ]] && ([[ "$@" == *"doctl" ]] || [ $ALL = "true" ]); then
    curl -OL https://github.com/digitalocean/doctl/releases/download/v1.0.0/doctl-1.0.0-linux-amd64.tar.gz
    tar xf doctl-1.0.0-linux-amd64.tar.gz
    sudo mv ./doctl /usr/local/bin
    rm -rf doctl-1.0.0-linux-amd64.tar.gz
    DOCTL=true
  fi
  
  # Heroku
  if [[ ! "$@" == *"-heroku"* ]] && ([[ "$@" == *"heroku"* ]] || [ $ALL = "true" ]); then
    wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
    HEROKU=true
  fi
  
  # S3CMD
  if [[ ! "$@" == *"-s3cmd"* ]] && ([[ "$@" == *"s3cmd"* ]] || [ $ALL = "true" ]); then
    wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add -
    sudo wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list
    sudo apt-get install -y s3cmd
    S3CMD=true
  fi
  
  # ------------------------------------------------
  # Start installed servers
  # ------------------------------------------------
  cd ~/ && source $HOME/.bash_profile
  
  # ------------------------------------------------
  # Access notes for web servers by port
  # ------------------------------------------------
  echo "--------------------------------------------"
  echo "Setup complete"
  if [ "$CLOUD9" == "true" ] && [ ! "$C9IO" = "true" ]; then
    echo "--------------------------------------------"
    echo "C9 browser IDE can be opened in your browser at:"
    echo "http://127.0.0.1:${C9_PORT}/"
  fi
  
  if [ "$EMBY" = "true" ]; then
    echo "--------------------------------------------"
    echo "Emby can be opened in your browser at:"
    echo " http://127.0.0.1:8096/"
  fi
  
  if [ "$DELUGE" = "true" ]; then
    echo "--------------------------------------------"
    echo "Deluge can be opened in your browser at:"
    echo " http://127.0.0.1:${DELUGE_PORT}/ password 'deluge'"
  fi

  if [ "$GITWEBUI" = "true" ]; then
    echo "--------------------------------------------"
    echo "Git WebUI can be started in a repo:"
    echo ""
    echo " $ git webui --host 0.0.0.0 --no-browser --port ${GITWEBUI_PORT}"
    echo ""
    echo "Git WebUI can be opened in your browser at:"
    echo " http://127.0.0.1:${GITWEBUI_PORT}/"
  fi
  
  if [ "$PGWEB" = "true" ]; then
    echo "--------------------------------------------"
    echo "pgweb can be opened in your browser at:"
    echo " http://127.0.0.1:${PGWEB_PORT}/"
  fi
  
  if [ "$REDIS_COMMANDER" = "true" ]; then
    echo "--------------------------------------------"
    echo "redis-commander can be opened in your browser at:"
    echo " http://127.0.0.1:${REDIS_COMMANDER_PORT}/"
  fi  
  # ------------------------------------------------
  # Setup notes for tools in alphabetical order
  # ------------------------------------------------
  # TODO: what would you like to add...
  if [ "$DROPBOX" = "true" ]; then
    echo "--------------------------------------------"
    echo "Dropbox setup can be completed by:"
    echo ""
    echo " $ $HOME/.dropbox-dist/dropboxd"
    echo ""
    echo " # exclude folders with selective sync:"
    echo " $ ~/dropbox.py exclude add a_folder"
    echo ""
    echo " # exclude all folders except 'chromedev' (run a few times)":
    echo " $ cd ~/Dropbox && for x in *; do if [ ! \"\$x\" = \"chromedev\" ]; then ~/dropbox.py exclude add \"\$x\"; fi done"
    echo ""
    echo " # replace ~/projects with ~/Dropbox/chromedev:"
    echo " $ rm -rf ~/projects && ln -s ~/Dropbox/chromedev ~/projects"
  fi
   
  if [ "$REDIS" = "true" ]; then
    echo "-------------------------------------------"
    echo "Redis setup can be completed with:"
    echo ""
    echo " $ cd ~/redis-stable/utils && sudo bash install_server.sh"
  fi
   
  if [ "$POSTGRESQL" = "true" ]; then
    echo "-------------------------------------------"
    echo "PostgreSQL is running on port 5432 and"
    echo "waiting for you to create a database:"
    echo ""
    echo " $ sudo -i -u postgres"
    echo " $ createuser -P -s -e mydb"
    echo " $ createdb mydb --owner mydb"
  fi
  
  # ------------------------------------------------
  # Hosting services installed in alphabetical order
  # ------------------------------------------------
  # TODO: what would you like to add...
  if [ "$AWSCLI" = "true" ]; then
    echo "--------------------------------------------"
    echo "AWS CLI is installed"
  fi
  
  if [ "$DOCTL" = "true" ]; then
    echo "--------------------------------------------"
    echo "DOCTL is installed"
  ff
  
  if [ "$HEROKU" = "true" ]; then
    echo "--------------------------------------------"
    echo "Heroku is installed and waiting for:"
    echo " $ heroku login"
  fi
  
  if [ "$S3CMD" = "true" ]; then
    echo "--------------------------------------------"
    echo "S3CMD is installed"
  fi
  
  # ------------------------------------------------
  # New SSH key
  # ------------------------------------------------
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
  
  echo "--------------------------------------------"
  echo "This is your new SSH key:"
  echo ""
  echo "`cat $HOME/.ssh/id_rsa.pub`"
}
