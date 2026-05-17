#!/usr/bin/env bash
# Initialize RHCSA Exam Environment
# This script sets up all required files and configurations

set -e

echo "Initializing RHCSA Exam Simulator..."

# Create required directories
mkdir -p "$HOME"

# Create progress tracking files
if [[ ! -f "$HOME/.exam_progress" ]]; then
    echo "0" > "$HOME/.exam_progress"
    echo "✓ Created progress file"
fi

if [[ ! -f "$HOME/.exam_timer" ]]; then
    date +%s > "$HOME/.exam_timer"
    echo "✓ Created timer file"
fi

# Copy questions file if not exists
if [[ ! -f "$HOME/questions.txt" ]] && [[ -f "questions.txt" ]]; then
    cp questions.txt "$HOME/questions.txt"
    echo "✓ Copied questions file"
fi

# Make exam menu executable
if [[ -f "rhcsa_exam_menu.sh" ]]; then
    chmod +x rhcsa_exam_menu.sh
    echo "✓ Made exam menu executable"
fi

# Make setup script executable
if [[ -f "setup_lab_ubuntu.sh" ]]; then
    chmod +x setup_lab_ubuntu.sh
    echo "✓ Made setup script executable"
fi

# Create alias for easy access
if ! grep -q "alias rhcsa-exam" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# RHCSA Exam Simulator" >> "$HOME/.bashrc"
    echo "alias rhcsa-exam='cd /workspaces/rhcsa-exam-simulator && ./rhcsa_exam_menu.sh'" >> "$HOME/.bashrc"
    echo "✓ Created rhcsa-exam alias"
fi

# Auto-start exam on shell login (optional - commented out by default)
# Uncomment the lines below to auto-start exam when opening terminal
# if ! grep -q "rhcsa_exam_menu.sh" "$HOME/.bashrc" 2>/dev/null; then
#     echo "" >> "$HOME/.bashrc"
#     echo "# Auto-start RHCSA Exam" >> "$HOME/.bashrc"
#     echo "cd /workspaces/rhcsa-exam-simulator 2>/dev/null && ./rhcsa_exam_menu.sh" >> "$HOME/.bashrc"
#     echo "✓ Configured auto-start on login"
# fi

echo ""
echo "✅ RHCSA Exam Simulator initialized successfully!"
echo ""
echo "To start the exam, run:"
echo "  ./rhcsa_exam_menu.sh"
echo ""
echo "Or use the alias:"
echo "  rhcsa-exam"
echo ""

# Made with Bob
