#!/bin/bash

export MIX_ENV=dev

envup () {
    if [ -f ${1} ]; then
        set -o allexport
        export $(grep -v '#.*' ${1} | xargs)
        set +o allexport
    else echo "Could not find ${1}"
    fi
}

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
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
    source ~/.bashrc

    cp .tool-versions ~
    asdf plugin-update --all
}

install_postgresql () {
    echo "installing postgresql"

     export POSTGRES_USER="${USER}"
	 export POSTGRES_PASSWORD="postgres"
	 export POSTGRES_DB="naboo"
     export POSTGRES_TEST_DB="${POSTGRES_DB}_test"

	 sudo apt-get install -y postgresql postgresql-contrib libpq-dev || true
	 sudo -u postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD $POSTGRES_PASSWORD';"
	 sudo -u postgres psql -c "GRANT postgres TO $POSTGRES_USER;"
	 sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_DB;"
	 sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;"
	 sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_TEST_DB;"
	 sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_TEST_DB TO $POSTGRES_USER;"
}

envup .env.${MIX_ENV}

install_elixir_with_asdf
install_postgresql

make dependencies && mix assets.deploy && mix ecto.create
