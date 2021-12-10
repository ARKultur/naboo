#!/bin/bash

install_elixir_with_asdf () {
    echo "installing ASDF dependencies..."
    sudo apt-get install -y \
        build-essential \
        git \
        wget \
        libssl-dev \
        libreadline-dev \
        libncurses5-dev \
        zlib1g-dev \
        m4 \
        curl \
        wx-common \
        libwxgtk3.0-dev \
        autoconf

    echo "installing ASDF"
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
    source ~/.bashrc

    cp .tool-versions ~
    asdf plugin-update --all
}

install_postgresql () {
    echo "installing postgresql"

    sudo apt install -y postgresql postgresql-contrib
    printf "$USER\ny\n" | sudo -u postgres createuser --interactive
    sudo -u postgres createdb ${USER}
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
}

install_elixir_with_asdf
install_postgresql

make dependencies
mix assets.deploy

mix ecto.create
