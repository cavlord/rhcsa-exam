#!/bin/bash

# Wait for system to be ready
sleep 2

# Make scripts executable
chmod +x /root/*.sh

# Run the lab setup
cd /root
bash ./setup_lab_ubuntu.sh || true

echo ""
echo "=========================================="
echo "Lab environment ready!"
echo "=========================================="
echo ""
echo "Starting RHCSA Exam Menu..."
sleep 1

# Launch exam menu
exec bash ./rhcsa_exam_menu.sh

# Made with Bob
