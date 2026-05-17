#!/bin/bash

# Wait for system to be ready
sleep 2

# Make scripts executable
chmod +x /root/*.sh

# Run the lab setup
cd /root
./setup_lab.sh

echo "Lab environment ready!"
