#!/usr/bin/env bash

# This script assumes you have SSH access to your Pi using keys, not passwords.

# Check if SSH_USER is set, if not, use the current user
ssh_user="${SSH_USER:-$USER}"
remote_host="$1"

# Define the source and destination paths
agent_service_source_file="/tmp/homelab-agent.service"
agent_service_destination_file="/etc/systemd/system/homelab-agent.service"

# First, we setup the repo.
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

EOF


# Run the following commands on the remote host
ssh "$ssh_user@$remote_host" << EOF
    sudo mv "$service_source_file" "$service_destination_file"
    sudo chmod 644 "$service_destination_file"
    sudo systemctl daemon-reload
    sudo systemctl enable homelab-agent
    sudo systemctl restart homelab-agent
EOF