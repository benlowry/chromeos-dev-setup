# Chrome OS for web dev
    
## What's installed
- NodeJS with nvm: https://github.com/creationix/nvm
- Golang
- Python
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
    
    $ EMAIL=you@youremail.com curl -o- https://raw.githubusercontent.com/benlowry/chromeos-setup/master/setup.sh | bash
    
## TODO:
1) automate startup of postgresql, c9, pgweb, deluge 

3) dns server for friendly names on all the other stuff

4) music player of some sort

## Starting servers

### Cloud9, a browser based IDE on YOUR_IP:81
    cd ~/c9
    node server.js -w ~/projectfolder --listen 0.0.0.0 --port=81

### pgweb, a browser based RDBMS for Postgresql
    $GOPATH/bin/pgweb —bind=0.0.0.0 —listen=82
    
### deluge, a torrent server with web interface
    /usr/bin/deluge-web
    
### Dropbox, first run it will generate a URL to link your computer
    ~/.dropbox-dist/dropboxd
