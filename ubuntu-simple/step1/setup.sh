#!/bin/bash

# Wait for system to be ready
sleep 2

# Make scripts executable
chmod +x /root/*.sh

# Run the lab setup (menu will be launched from within setup_lab_ubuntu.sh)
cd /root
bash ./setup_lab_ubuntu.sh
