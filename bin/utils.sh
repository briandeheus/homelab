#!/usr/bin/env bash

install_homelab() {
  ssh_user=$1
  remote_host=$2

  ssh "$ssh_user@$remote_host" << EOF
    sudo apt install git python3-venv -y
    sudo useradd -m -s /bin/bash homelab
    sudo su - homelab
    rm -rf homelab
    git clone https://github.com/briandeheus/homelab.git
    cd homelab
    python -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    exit
EOF
}

update_homelab() {
  ssh_user=$1
  remote_host=$2

  ssh "$ssh_user@$remote_host" << EOF
    sudo su - homelab
    cd homelab
    git fetch origin main
    python -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    exit
EOF
}