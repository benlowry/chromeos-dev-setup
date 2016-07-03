# Automated setup for programming on Chrome OS

This setup script for installing Ubuntu core on Crouton for web dev using an x86 Chrome OS device.  It is 
compatible with C9.io so dev environments can be created locally where possible and replicated remotely.

*This script is public domain and may be used or modified in any way.*

To use this you'll need [crouton](https://github.com/dnschneid/crouton) and developer mode ready.

    $ sudo sh ~/Downloads/crouton -r trusty -t core -n my_chroot_name
    $ sudo enter-chroot
    $ sudo apt-get install -y curl
    $ curl https://raw.githubusercontent.com/benlowry/chromeos-setup/master/setup.sh > setup.sh 
    
    # install everything
    $ bash setup.sh
    
    # install only these things
    $ bash setup.sh nodejs cloud9 awscli
    
    # install everything except
    $ bash setup.sh -deluge -s3cmd -awscli -doctl -dropbox
    
    # backup a configured machine
    $ sudo edit-chroot -b my_chroot_name
    $ mv my_chroot_name*.zip /media/removable/SD\ Card/
    
    # restore a backup
    $ cp /media/removable/SD\ Card/my_chroot_name*.zip .
    $ sudo edit-chroot -r my_chroot_name

## What can be installed
- `golang` Golang
- `python` Python 2.7
- `nodejs` NodeJS via nvm: https://github.com/creationix/nvm
- `git-webui` Git + Git-WebUI: https://github.com/alberthier/git-webui
- `postgresql` Postgresql + pgweb: https://github.com/sosedoff/pgweb
- `cloud9` Cloud9 IDE: https://github.com/c9/core
- `awscli` Amazon's  AWS CLI: http://docs.aws.amazon.com/cli/latest/userguide/installing.html
- `s3cmd` S3Tools' S3CMD: http://s3tools.org/s3cmd
- `doctl` DigitalOcean's doctl: https://github.com/digitalocean/doctl/
- `heroku` Heroku Toolbelt: https://toolbelt.heroku.com/debian
- `deluge` Deluge torrent server and web client: http://deluge-torrent.org/
- `emby` Emby Media Server: https://emby.media/
- `dropbox` Dropbox: https://www.dropbox.com/
- New SSH key generated with your email

## After setup finishes
If installed ...
- Cloud9 will be running with ~/projects as the workspace folder.  
- postgres will be running but has no databases etc
- pgweb will be running with local server pre-configured
- git-webui will not be running, you need to start this within your git repo
- Dropbox requires connecting your account
- Emby requires adding your music library
- Deluge is running and the password is `deluge`

## Backing up and restoring
You can backup your fully configured chroot with:

    cd /usr/local/chroots/
    sudo edit-chroot -b my_chroot_name
    mv *.zip ~/Downloads
    
This will generate a zip file you can safeguard on any external storage because it will be
deleted by ChromeOS if it does a powerwash.  To restore the zip:

    cd /usr/local/chroots/
    cp ~/Downloads/my_chroot*.zip .
    sudo edit-chroot -r my_chroot_name
    rm -rf *.zip
    
## Accessing servers
### Cloud9 http://127.0.0.1:8080
Note: this does not get installed on c9.io

    $ cd ~/c9
    $ sudo node server.js -w ~/projects --listen 0.0.0.0 --port=8080

### git-webui http://127.0.0.1:8081

    $ cd my_project && git webui -p 8081 

### pgweb http://127.0.0.1:8082 a browser based RDBMS for Postgresql 
    
    $ sudo $GOPATH/bin/pgweb --bind=0.0.0.0 --listen=8082
    
### Dropbox
Note: first run it will generate a URL to link your computer
  
    $ ~/.dropbox-dist/dropboxd
    
Exclude folders via selective sync:

    $ ~/dropbox.py exclude add my_folder
    
Exclude all folders but 'chromedev', this needs to be run
several times and Dropbox will manage deleting any files
that become deselected:
    
    $ cd ~/Dropbox && for x in *; do if [ ! "$x" = "chromedev" ]; then ~/dropbox.py exclude add "$x"; fi done;
    
Replace ~/projects with ~/Dropbox/chromedev:

    $ rm -rf ~/projects && ln -s ~/Dropbox/chromedev ~/projects

### Deluge http://127.0.0.1:8112
Note: this does not get installed on c9.io

    $ sudo /usr/bin/deluge-web --no-ssl -p 8112
    
### Emby Media Server http://127.0.0.1:8096/
Note: this does not get installed on c9.io

    $ sudo /usr/bin/emby-server start

### Postgres on port 5432
You will need to create a user and database:

    $ sudo -i -u postgres
    $ createuser -P -s -e mydb
    $ createdb mydb --owner mydb

## Screenshots

### Cloud9
A full-featured, open source IDE.

Github: https://github.com/

Website: https://c9.io/

<a href='https://raw.github.com/benlowry/chromeos-setup/master/cloud9.png'><img src="https://raw.github.com/benlowry/chromeos-setup/master/cloud9.png" width="250"/></a>

### PGWeb
A web interface for managing PostgreSQL databases.

Github: https://github.com/sosedoff/pgweb

<a href='https://raw.github.com/benlowry/chromeos-setup/master/pgweb.png'><img src="https://raw.github.com/benlowry/chromeos-setup/master/pgweb.png" width="250"/></a>

### Git WebUI
A web interface for git.

Github: https://github.com/alberthier/git-webui

<a href='https://raw.github.com/benlowry/chromeos-setup/master/gitwebui.png'><img src="https://raw.github.com/benlowry/chromeos-setup/master/gitwebui.png" width="250"/></a>

### Deluge
A web server and interface for torrents.

Github: https://github.com/deluge-torrent

Website: http://deluge-torrent.org/

<a href='https://raw.github.com/benlowry/chromeos-setup/master/deluge.png'><img src="https://raw.github.com/benlowry/chromeos-setup/master/deluge.png" width="250"/></a>

### Emby
A media server and interface for audio/video.

Github: https://github.com/MediaBrowser/Emby

Website: http://emby.media/

<a href='https://raw.github.com/benlowry/chromeos-setup/master/emby.png'><img src="https://raw.github.com/benlowry/chromeos-setup/master/emby.png" width="250"/></a>
    
