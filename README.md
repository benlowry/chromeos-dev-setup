# Automated setup for programming on Chrome OS

This setup script for installing Ubuntu core on Crouton for working on more powerful x86 Chrome OS 
devices.  It is compatible with C9.io so the same environment can be created on or off your 
hardware.  It can use Dropbox to sync your IDE settings and work in progress, and includes browser
based media and torrent clients.

All of the software installed uses web or CLI interfaces so the 'chroot' doesn't install a GUI, if you
want to also install an interface and desktop software change `core` to `xfce` when running `crouton`.

If you would like to add something please submit a pull request with your addition, it must include
an updated README and a screenshot and links if it has a web interface.  Improvements to the setup
script are also welcome.

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
    $ mv /etc/local/chroots/my_chroot_name*.zip /media/removable/SD\ Card/
    
    # restore a backup
    $ cp /media/removable/SD\ Card/my_chroot_name*.zip /etc/local/chroots/
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

## Accessing servers
On [C9.io](https://c9.io) you use your workspace URL instead of localhost.
### Cloud9 http://localhost:8080 (also port 80 on c9.io)
### git-webui http://localhost:8081
### pgweb http://localhost:8082
### Deluge http://localhost:8112 (not on c9.io)
### Emby Media Server http://localhost:8096/  (not on c9.io)

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

### Postgres on port 5432
You will need to create a user and database:

    $ sudo -i -u postgres
    $ createuser -P -s -e mydb
    $ createdb mydb --owner mydb

## Screenshots
<a href='https://raw.github.com/benlowry/chromeos-setup/master/cloud9.png' title='Cloud9 - an open source IDE'><img src="https://raw.github.com/benlowry/chromeos-setup/master/cloud9.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/pgweb.png' title='PGWeb - an open source web interface for PostgreSQL databases'><img src="https://raw.github.com/benlowry/chromeos-setup/master/pgweb.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/gitwebui.png' title='Git WebUI - an open source web interface for git repistories.'><img src="https://raw.github.com/benlowry/chromeos-setup/master/gitwebui.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/deluge.png' title='Deluge - an open source web server and interface for torrents'><img src="https://raw.github.com/benlowry/chromeos-setup/master/deluge.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/emby.png' title='Emby - 
an open source media server and interface for audio/video'><img src="https://raw.github.com/benlowry/chromeos-setup/master/emby.png" width="250"/></a>
    
