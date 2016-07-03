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
- `golang` Golang via https://launchpad.net/~ubuntu-lxc/+archive/ubuntu/lxd-stable
- `python` Python 2.7 via https://launchpad.net/~fkrull/+archive/ubuntu/deadsnakes-python2.7
- `nodejs` NodeJS via nvm: [creationix/nvm](https://github.com/creationix/nvm)
- `git-webui` Git + Git-WebUI: [alberthier/git-webui](https://github.com/alberthier/git-webgui)
- `postgresql` Postgresql + pgweb: [sosedoff/pgweb](https://github.com/sosedoff/pgweb)
- `cloud9` Cloud9 IDE: [c9/core](https://github.com/c9/core)
- `awscli` Amazon's  AWS CLI: http://docs.aws.amazon.com/cli/latest/userguide/installing.html
- `s3cmd` S3Tools' S3CMD: http://s3tools.org/s3cmd
- `doctl` DigitalOcean's doctl: [digitalocean/doctl](https://github.com/digitaloceal/doctl)
- `heroku` Heroku Toolbelt: [toolbelt.heroku.com/debian](https://toolbelt.heroku.com/debian)
- `deluge` Deluge torrent server and web client: [deluge-torrent.org](http://deluge-torrent.org/)
- `emby` Emby Media Server: [emby.media](http://emby.media)
- `dropbox` Dropbox: [dropbox.com](https://www.dropbox.com/)
- New SSH key generated with your email

## After setup finishes
If installed, note that On [C9.io](https://c9.io) you use your workspace URL not localhost.
- Cloud9 will be running at [localhost:8080](http://localhost:8080) ~/projects as the workspace folder.  
- postgres will be running at localhost:5432 but has no databases etc
- git-webui must be started in a git reop, then running at [localhost:8081](http://localhost:8081)
- pgweb will be running at [localhost:8082](http://localhost:8082)
- Dropbox requires connecting your account
- Emby will be running at [localhost:8096](http://localhost:8096)
- Deluge will be running at [localhost:8112](http://localhost:8112), password 'deluge'

## Screenshots
<a href='https://raw.github.com/benlowry/chromeos-setup/master/cloud9.png' title='Cloud9 - an open source IDE'><img src="https://raw.github.com/benlowry/chromeos-setup/master/cloud9.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/pgweb.png' title='PGWeb - an open source web interface for PostgreSQL databases'><img src="https://raw.github.com/benlowry/chromeos-setup/master/pgweb.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/gitwebui.png' title='Git WebUI - an open source web interface for git repistories.'><img src="https://raw.github.com/benlowry/chromeos-setup/master/gitwebui.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/deluge.png' title='Deluge - an open source web server and interface for torrents'><img src="https://raw.github.com/benlowry/chromeos-setup/master/deluge.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/emby.png' title='Emby - 
an open source media server and interface for audio/video'><img src="https://raw.github.com/benlowry/chromeos-setup/master/emby.png" width="250"/></a>

### Finishing Postgres setup
You will need to create a user and database:

    $ sudo -i -u postgres
    $ createuser -P -s -e mydb
    $ createdb mydb --owner mydb
    
### Finishing Dropbox setup
Note: first run it will generate a URL to link your computer
  
    # follow the link it generates
    $ ~/.dropbox-dist/dropboxd
    
    # exclude folders via selective sync:
    $ ~/dropbox.py exclude add my_folder
    
    # exclude all folders but 'chromedev' (run multiple times)
    $ cd ~/Dropbox && for x in *; do if [ ! "$x" = "chromedev" ]; then ~/dropbox.py exclude add "$x"; fi done;
    
    # replace ~/projects with ~/Dropbox/chromedev:
    $ rm -rf ~/projects && ln -s ~/Dropbox/chromedev ~/projects
