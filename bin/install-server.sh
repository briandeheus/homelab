#!/usr/bin/env bash

# This script assumes you have SSH access to your Pi using keys, not passwords.

# Load shared modules.
source ./bin/utils.sh

# Define the source and destination paths
service_source_file="/tmp/homelab-server.service"
service_destination_file="/etc/systemd/system/homelab-server.service"

# Check if SSH_USER is set, if not, use the current user
ssh_user="${SSH_USER:-$USER}"
remote_host="$1"

# Install homelab first.
install_homelab $ssh_user $remote_host

cat << EOF > $service_source_file
[Unit]
Description=Brian's Homelab Server
After=network-online.target
Wants=network-online.target

[Service]
User=homelab
Group=homelab
ExecStart=/home/homelab/homelab/.venv/bin/fastapi run /home/homelab/homelab/server.py --host 127.0.0.1 --port 8000
WorkingDirectory=/home/homelab/homelab
Environment="PATH=/home/homelab/homelab/.venv/bin:/usr/bin:/bin"
Restart=always

[Install]
WantedBy=default.target
EOF

# Next up we need to copy the system files over.
scp $service_source_file "$ssh_user@$remote_host:$service_source_file"

# Run the following commands on the remote host
ssh "$ssh_user@$remote_host" << EOF
    sudo mv "$service_source_file" "$service_destination_file"
    sudo chmod 644 "$service_destination_file"
    sudo systemctl daemon-reload
    sudo systemctl enable homelab-server
    sudo systemctl restart homelab-server
EOF