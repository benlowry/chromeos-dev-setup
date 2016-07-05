# Automated setup for programming on Chrome OS

This setup script for installing Ubuntu core on Crouton for working on more powerful x86 Chrome OS
devices.  It is compatible with C9.io so the same environment can be created on or off your
hardware.  It can use Dropbox to sync your IDE settings and work in progress, and includes browser
based media and torrent clients.

All of the software installed uses web or CLI interfaces so the 'chroot' doesn't install a GUI, if you
want to also install an interface and desktop software change `core` to `xfce` when running `crouton`.

*This script is public domain and may be used or modified in any way.*

## Pull requests
If you would like to add something please submit a pull request with your addition, it must include
an updated README and a screenshot etc where applicable.  Improvements to the setup script are welcome.

## Running the setup
To use this you'll need [crouton](https://github.com/dnschneid/crouton) and developer mode ready.

    $ sudo sh ~/Downloads/crouton -r trusty -t core -n my_chroot_name
    $ sudo enter-chroot
    $ sudo apt-get install -y curl
    $ curl https://raw.githubusercontent.com/benlowry/chromeos-setup/releases/setup.sh > setup.sh

    # install everything
    $ bash setup.sh

    # install only these things
    $ bash setup.sh nodejs cloud9 awscli

    # install everything except
    $ bash setup.sh -deluge -s3cmd -awscli -doctl -dropbox

    # backup a configured machine
    $ sudo edit-chroot -b my_chroot_name -f /media/removable/SD\ Card/

    # restore a backup
    $ sudo edit-chroot -r my_chroot_name -f /media/removable/SD\ Card/

## What can be installed
### Browser-based software
- `cloud9` [Cloud9 IDE](https://github.com/c9/core)
- `deluge` [Deluge torrent server](http://deluge-torrent.org/) (insecure link)
- `emby` [Emby Media Server](http://emby.media)  (insecure link)
- `git-webui` [Git-WebUI](https://github.com/alberthier/git-webgui)
- `redis-commander` [redis-commander](https://github.com/joeferner/redis-commander)
- `pgweb` [pgweb ](https://github.com/sosedoff/pgweb)

### Languages
- `golang` via [lxd-stable](https://launchpad.net/~ubuntu-lxc/+archive/ubuntu/lxd-stable)
- `nodejs` via [NVM](https://github.com/creationix/nvm)
- `python` version 2.7 via [deadsnakes](https://launchpad.net/~fkrull/+archive/ubuntu/deadsnakes-python2.7)

### Tools
- `dropbox` [Dropbox](https://www.dropbox.com/)
- `redis` [Redis](http://redis.io/)  (insecure link)
- `postgresql` [PostgreSQL](https://postgresql.org/)

### Hosting services
- `awscli` [Amazon's  AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)  (insecure link)
- `doctl` [DigitalOcean's doctl](https://github.com/digitaloceal/doctl)
- `heroku` [Heroku Toolbelt](https://toolbelt.heroku.com/debian)
- `s3cmd` [S3Tools' S3CMD](http://s3tools.org/s3cmd)  (insecure link)

## After setup finishes
If installed, note that On [C9.io](https://c9.io) you use your workspace URL not localhost:

- Cloud9 will be running at [localhost:8080](http://localhost:8080) ~/projects as workspace
- PGWeb will be running at [localhost:8081](http://localhost:8081)
- Git WebUI runs at [localhost:8082](http://localhost:8082) after `git webui` in a repo
- redis-commander runs at [localhost:8083](http://localhost:8083)
- Emby will be running at [localhost:8096](http://localhost:8096)
- Deluge will be running at [localhost:8112](http://localhost:8112), password 'deluge'
- Dropbox requires connecting your account
- PostgreSQL on port 5432 will be waiting to create databases and users
- Redis on port 6379 will be waiting for final setup `cd ~/redis-stable/utils && sudo bash install_server.sh`

## Screenshots
<a href='https://raw.github.com/benlowry/chromeos-setup/master/screenshots/cloud9.png' title='Cloud9 - an open source IDE'><img src="https://raw.github.com/benlowry/chromeos-setup/master/screenshots/cloud9.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/screenshots/deluge.png' title='Deluge - an open source web server and interface for torrents'><img src="https://raw.github.com/benlowry/chromeos-setup/master/screenshots/deluge.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/screenshots/emby.png' title='Emby -
an open source media server and interface for audio/video'><img src="https://raw.github.com/benlowry/chromeos-setup/master/screenshots/emby.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/screenshots/gitwebui.png' title='git-webui - an open source web interface for git repistories.'><img src="https://raw.github.com/benlowry/chromeos-setup/master/screenshots/gitwebui.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/screenshots/pgweb.png' title='PGWeb - an open source web interface for PostgreSQL databases'><img src="https://raw.github.com/benlowry/chromeos-setup/master/screenshots/pgweb.png" width="250"/></a>
<a href='https://raw.github.com/benlowry/chromeos-setup/master/screenshots/redis-commander.png' title='redis-commander - an open source web interface for Redis'><img src="https://raw.github.com/benlowry/chromeos-setup/master/screenshots/redis-commander.png" width="250"/></a>

### Finishing PostgreSQL setup
You will need to create a user and database:

    $ sudo -i -u postgres
    $ createuser -P -s -e mydb
    $ createdb mydb --owner mydb

### Finishing Redis setup
Redis requires running an installation script to configure the port and folders:

    $ cd ~/redis-stable/utils && sudo bash install_server.sh

### Finishing Dropbox setup
Note: first run it will generate a URL to link your computer:

    # follow the link it generates, eventually press ctrl+c to quit
    $ ~/.dropbox-dist/dropboxd

    # exclude folders via selective sync:
    $ ~/dropbox.py exclude add my_folder

    # exclude all folders but 'chromedev' (run multiple times)
    $ cd ~/Dropbox && for x in *; do if [ ! "$x" = "chromedev" ]; then ~/dropbox.py exclude add "$x"; fi done;

    # replace ~/projects with ~/Dropbox/chromedev:
    $ rm -rf ~/projects && ln -s ~/Dropbox/chromedev ~/projects
