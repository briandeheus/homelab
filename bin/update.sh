#!/usr/bin/env bash

# This script assumes you have SSH access to your Pi using keys, not passwords.

# Check if SSH_USER is set, if not, use the current user
ssh_user="${SSH_USER:-$USER}"
remote_host="$1"

# First, we setup the repo.
ssh "$ssh_user@$remote_host" << EOF

  sudo su - homelab
  cd homelab
  git fetch origin
  source .venv/bin/activate
  pip install -r requirements.txt
  sudo systemctl restart homelab-agent
EOF