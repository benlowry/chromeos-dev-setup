# Chrome OS for web dev
    
## What's installed
- NodeJS with nvm: https://github.com/creationix/nvm
- Golang
- Python
- Cloud9 IDE: https://github.com/c9/core
- Postgresql + pgweb: https://github.com/sosedoff/pgweb
- Deluge torrent server+client
- New SSH key generated with your email

## TODO:
1) automate startup of postgresql, c9, pgweb, deluge 

3) dns server for friendly names on all the other stuff

4) music player of some sort

## Running the setup
1) Download crouton to ~/Downloads and open a terminal ctrl+alt+t

    $ shell
    
    $ sudo sh ~/Downloads/crouton -r trusty -t core
    
2) Once it’s finished setting up

    $ sudo enter-chroot
    
    $ sudo apt-get install -y curl
    
    $ EMAIL=you@youremail.com curl -o- https://raw.githubusercontent.com/benlowry/chromeos-setup/master/setup.sh | bash

