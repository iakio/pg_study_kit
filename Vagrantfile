# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update && apt-get install -y \
      build-essential \
      libreadline-dev \
      libssl-dev \
      quilt
  SHELL
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 
    nvm install node
    nvm use node

    mkdir $HOME/src
    curl -o- https://ftp.postgresql.org/pub/source/v9.6.2/postgresql-9.6.2.tar.bz2 | tar jxf - -C $HOME/src
    cd $HOME/src/postgresql-9.6.2
    export QUILT_PATCHES=/vagrant/src/patches
    quilt push -a
    ./configure --prefix=$HOME
    make install
  SHELL
end
