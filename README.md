# Chrome OS for web dev
This repo is a setup script for installing Ubuntu core on Crouton for web dev using an x86 Chrome OS device.

It is intended to be compatible with C9.io so dev environments can be replicated locally and remotely
for non-x86 Chrome OS devices or resource-constrained ones.
    
## What is installed
- Golang, Python, NodeJS via nvm: https://github.com/creationix/nvm
- Git + Git-WebUI: https://github.com/alberthier/git-webui
- Postgresql + pgweb: https://github.com/sosedoff/pgweb
- Cloud9 IDE: https://github.com/c9/core
- Deluge torrent server+client
- Dropbox
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
    
## Starting servers
### Cloud9 http://127.0.0.1:8080 a browser based IDE 
Note: this is pre-installed on c9.io and port 8080 also maps to port 80.

    $ cd ~/c9
    $ sudo node server.js -w ~/projectfolder --listen 0.0.0.0 --port=8080

### git-webui http://127.0.0.1:8081 a browser UI for git
  
    $ cd my_project && git webui -p 8081 

### pgweb http://127.0.0.1:8082 a browser based RDBMS for Postgresql on 
    
    $ sudo $GOPATH/bin/pgweb --bind=0.0.0.0 --listen=8082

### deluge http://127.0.0.1:8083 a torrent server with web interface on
Note: this does not get installed on c9.io

    $ sudo /usr/bin/deluge-web --no-ssl -p 8083
    
### Dropbox, first run it will generate a URL to link your computer
  
    $ ~/.dropbox-dist/dropboxd
