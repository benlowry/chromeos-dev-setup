# Chrome OS for web dev
    
## What's installed
- NodeJS with nvm: https://github.com/creationix/nvm
- Golang
- Python
- Git + Git-WebUI: https://github.com/alberthier/git-webui
- Cloud9 IDE: https://github.com/c9/core
- Postgresql + pgweb: https://github.com/sosedoff/pgweb
- Deluge torrent server+client
- New SSH key generated with your email

## Running the setup
1) Download crouton to ~/Downloads and open a terminal ctrl+alt+t

    $ shell
    
    $ sudo sh ~/Downloads/crouton -r trusty -t core
    
2) Once it’s finished setting up

    $ sudo enter-chroot
    
    $ sudo apt-get install -y curl
    
    $ curl https://raw.githubusercontent.com/benlowry/chromeos-setup/master/setup.sh > setup.sh 
    
    $ bash setup.sh
    
### Options
Pass any combination of these to tailor the installation to your needs.  If you specify what
to install anything you do not include will not be installed.  If you don't pass anything it
will install everything.

    $ bash setup.sh golang postgres pgweb

    - golang
    - python
    - nodejs
    - postgres
    - dropbox
    - deluge
    - pgweb
    - git-webui
    - c9
    
## TODO:
1) automate startup of postgresql, c9, pgweb, deluge 

3) dns server for friendly names on all the other stuff

4) music player of some sort

## Starting servers

### Cloud9 http://127.0.0.1:81 a browser based IDE 
    cd ~/c9
    sudo node server.js -w ~/projectfolder --listen 0.0.0.0 --port=81

### pgweb http://127.0.0.1:82 a browser based RDBMS for Postgresql on 
    sudo $GOPATH/bin/pgweb --bind=0.0.0.0 --listen=82
    
### deluge http://127.0.0.1:83 a torrent server with web interface on
    sudo /usr/bin/deluge-web -p 83 --no-ssl
    
### Dropbox, first run it will generate a URL to link your computer
    ~/.dropbox-dist/dropboxd
