#!/bin/bash

# Wait for system to be ready
sleep 2

# Make scripts executable
chmod +x /root/*.sh

# Run the lab setup
cd /root
./setup_lab_ubuntu.sh

echo ""
echo "=========================================="
echo "Lab environment ready!"
echo "=========================================="
echo ""
echo "To start the exam, run:"
echo "  ./rhcsa_exam_menu.sh"
echo ""
echo "Or view questions directly:"
echo "  cat questions.txt"
echo ""

# Made with Bob
