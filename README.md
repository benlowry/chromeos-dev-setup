# chromeos-setup


## TODO:
1) automate startup of postgresql, c9, pgweb, deluge 
2) install dropbox 
3) dns server for friendly names on all the other stuff
4) music player of some sort
5) ssh key generation and outputting the public key after everything
6) npm dependencies: jsbeautify, pm2
7) heroku toolbelt

## Setting up my crouton 
1) Download crouton to ~/Downloads and open a terminal ctrl+alt+t

    $ shell
    
    $ sudo sh ~/Downloads/crouton -r trusty -t core
    
2) Once it’s finished setting up

    $ sudo enter-chroot
    
    $ sudo apt-get install -y curl
    
    $ curl -o- https://raw.githubusercontent.com/benlowry/chromeos-setup/master/setup.sh | bash
    
# What's installed
- NodeJS with nvm: https://github.com/creationix/nvm
- Golang
- Python
- Cloud9 IDE: https://github.com/c9/core
- Postgresql + pgweb: https://github.com/sosedoff/pgweb
- Deluge torrent server+client
