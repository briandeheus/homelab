#!/usr/bin/env bash
# This script assumes you have SSH access to your Pi using keys, not passwords.

# Load shared modules.
source ./bin/utils.sh

# Check if SSH_USER is set, if not, use the current user
ssh_user="${SSH_USER:-$USER}"
remote_host="$1"

update_homelab $ssh_user $remote_host

ssh "$ssh_user@$remote_host" << EOF
    sudo systemctl restart homelab-server
EOF