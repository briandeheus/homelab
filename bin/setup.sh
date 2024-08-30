#!/usr/bin/env bash

# This script assumes you have SSH access to your Pi using keys, not passwords.

# Check if SSH_USER is set, if not, use the current user
ssh_user="${SSH_USER:-$USER}"
remote_host="$1"

# Define the source and destination paths
service_source_file="/tmp/homelab-agent.service"
service_destination_file="/etc/systemd/system/homelab-agent.service"

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

echo "We need to setup the agent, for this, we will ask a few questions..."

read -p "Enter the Discord Webhook URL: " discord_webhook_url

# Create the service file with the provided DISCORD_WEBHOOK_URL
cat << EOF > $service_source_file
[Unit]
Description=Brian's Homelab Agent
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=homelab
Group=homelab
ExecStart=/home/homelab/homelab/.venv/bin/python /home/homelab/homelab/agent.py
WorkingDirectory=/home/homelab/homelab
Environment="PATH=/home/homelab/homelab/.venv/bin:/usr/bin:/bin"
Environment="MESSAGING_PLATFORM=discord"
Environment="DISCORD_WEBHOOK_URL=$discord_webhook_url"
Environment="DISCORD_USERNAME=%H"
RemainAfterExit=true

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
    sudo systemctl enable homelab-agent
    sudo systemctl restart homelab-agent
EOF