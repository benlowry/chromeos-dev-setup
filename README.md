# Chrome OS for web dev
This setup script for installing Ubuntu core on Crouton for web dev using an x86 Chrome OS device.  It is 
compatible with C9.io so dev environments can be created locally on x86 devices or remotely for ARM and
resource constrained devices.

*This script is public domain and may be used or modified in any way.*

## What can be installed
Any or all of the following software can be installed.  Some require additional steps after installation.
When installation completes you'll be reminded of those steps, along with how to connect to each server
and your new SSH key.

- Golang, Python, NodeJS via nvm: https://github.com/creationix/nvm
- Git + Git-WebUI: https://github.com/alberthier/git-webui
- Postgresql + pgweb: https://github.com/sosedoff/pgweb
- Cloud9 IDE: https://github.com/c9/core
- Amazon's  AWS CLI: http://docs.aws.amazon.com/cli/latest/userguide/installing.html
- S3Tools' S3CMD: http://s3tools.org/s3cmd
- DigitalOcean's doctl: https://github.com/digitalocean/doctl/
- Heroku Toolbelt: https://toolbelt.heroku.com/debian
- Deluge torrent server and web client: http://deluge-torrent.org/
- Emby Media Server: https://emby.media/
- Dropbox: https://www.dropbox.com/
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

    # example 
    $ bash setup.sh golang postgres pgweb

    - golang
    - python
    - nodejs
    - postgres
    - dropbox
    - deluge
    - pgweb
    - git-webui
    - emby
    - c9
    - s3cmd
    - awscli
    - doctl
    - heroku
    
## After setup finishes
If installed ...
- Cloud9 will be running with ~/projects as the workspace folder.  
- postgres will be running but has no databases etc
- pgweb will be running with local server pre-configured
- git-webui will not be running, you need to start this within your git repo
- Dropbox requires connecting your account
- Emby requires adding your music library
- Deluge is running and the password is `deluge`
    
## Starting servers
### Cloud9 http://127.0.0.1:8080 a browser based IDE 
Note: this is pre-installed on c9.io, where port 8080 also maps to port 80.

    $ cd ~/c9
    $ sudo node server.js -w ~/projectfolder --listen 0.0.0.0 --port=8080

### git-webui http://127.0.0.1:8081 a browser UI for git
  
    $ cd my_project && git webui -p 8081 

### pgweb http://127.0.0.1:8082 a browser based RDBMS for Postgresql 
    
    $ sudo $GOPATH/bin/pgweb --bind=0.0.0.0 --listen=8082
    
### Dropbox
First run it will generate a URL to link your computer
  
    $ ~/.dropbox-dist/dropboxd

### Deluge http://127.0.0.1:8112 a torrent server with web interface
Note: this does not get installed on c9.io

    $ sudo /usr/bin/deluge-web --no-ssl -p 8112
    
### Emby Media Server http://127.0.0.1:8096/
Note: this does not get installed on c9.io

    $ sudo /usr/bin/emby-server start
