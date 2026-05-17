#!/bin/bash

# Wait for system to be ready
sleep 2

# Make scripts executable
chmod +x /root/*.sh

# Run the lab setup
cd /root
./setup_lab_ubuntu.sh

echo "Lab environment ready!"
echo ""
echo "Starting RHCSA Exam Menu..."
sleep 2

# Launch exam menu
./rhcsa_exam_menu.sh

# Made with Bob
