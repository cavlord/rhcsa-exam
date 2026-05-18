#!/usr/bin/env bash

# RHCSA Exam Simulator - Interactive Menu
# Auto-runs on boot and provides question-by-question navigation

# Use home directory for compatibility
QUESTIONS_FILE="$HOME/questions.txt"
PROGRESS_FILE="$HOME/.exam_progress"
TIMER_FILE="$HOME/.exam_timer"
EXAM_DURATION=7200  # 2 hours in seconds

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Initialize progress tracking
init_progress() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo "0" > "$PROGRESS_FILE"  # Current question
        echo "$(date +%s)" > "$TIMER_FILE"  # Start time
    fi
}

# Get elapsed time
get_elapsed_time() {
    local start_time=$(cat "$TIMER_FILE" 2>/dev/null || echo "$(date +%s)")
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    echo "$elapsed"
}

# Format time
format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $secs
}

# Get remaining time
get_remaining_time() {
    local elapsed=$(get_elapsed_time)
    local remaining=$((EXAM_DURATION - elapsed))
    if [[ $remaining -lt 0 ]]; then
        remaining=0
    fi
    echo "$remaining"
}

# Clear screen and show header
show_header() {
    clear
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║           RHCSA EXAM SIMULATOR - Interactive Mode              ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    
    local elapsed=$(get_elapsed_time)
    local remaining=$(get_remaining_time)
    local elapsed_fmt=$(format_time $elapsed)
    local remaining_fmt=$(format_time $remaining)
    
    if [[ $remaining -eq 0 ]]; then
        echo -e "${RED}${BOLD}⏰ TIME'S UP! Exam duration exceeded${NC}"
    else
        echo -e "${GREEN}⏱️  Time Elapsed: ${elapsed_fmt}${NC}  |  ${YELLOW}⏳ Remaining: ${remaining_fmt}${NC}"
    fi
    echo ""
}

# Display a specific question
show_question() {
    local question_num=$1
    show_header
    
    case $question_num in
        1)
            echo -e "${BOLD}${BLUE}Question 1: Configure Networking${NC}"
            echo ""
            echo "Configure the network with the following settings:"
            echo "  • IP Address: 192.168.1.6/24"
            echo "  • Gateway: 192.168.1.254"
            echo "  • DNS: 192.168.1.254"
            echo "  • Hostname: ibmid.example.com"
            echo ""
            echo -e "${YELLOW}Hint: Use nmcli or NetworkManager${NC}"
            ;;
        2)
            echo -e "${BOLD}${BLUE}Question 2: Configure DNF Repositories${NC}"
            echo ""
            echo "Configure the following repositories:"
            echo "  • BaseOS"
            echo "  • AppStream"
            echo ""
            echo -e "${YELLOW}Hint: Check /etc/yum.repos.d/${NC}"
            ;;
        3)
            echo -e "${BOLD}${BLUE}Question 3: Troubleshoot httpd Service${NC}"
            echo ""
            echo "Fix the httpd service to run on port 82"
            echo ""
            echo -e "${YELLOW}Hint: Check httpd configuration and firewall${NC}"
            ;;
        4)
            echo -e "${BOLD}${BLUE}Question 4: Create Users and Groups${NC}"
            echo ""
            echo "Create the following:"
            echo "  • Group: manager"
            echo "  • Users: simone, walhalla (in manager group)"
            echo "  • User: pandora (no interactive shell)"
            echo ""
            echo -e "${YELLOW}Hint: useradd, groupadd, usermod${NC}"
            ;;
        5)
            echo -e "${BOLD}${BLUE}Question 5: Configure Collaborative Directory${NC}"
            echo ""
            echo "Configure /shared/manager with:"
            echo "  • SGID enabled"
            echo "  • Accessible only by manager group"
            echo ""
            echo -e "${YELLOW}Hint: chmod 2770, chgrp${NC}"
            ;;
        6)
            echo -e "${BOLD}${BLUE}Question 6: Configure Cron Job${NC}"
            echo ""
            echo "Create a cron job for user walhalla:"
            echo "  • Run every minute"
            echo "  • Command: logger \"EX200 Test\""
            echo ""
            echo -e "${YELLOW}Hint: crontab -e -u walhalla${NC}"
            ;;
        7)
            echo -e "${BOLD}${BLUE}Question 7: Configure Autofs${NC}"
            echo ""
            echo "Configure autofs to automount simone's home directory"
            echo ""
            echo -e "${YELLOW}Hint: /etc/auto.master, /etc/auto.home${NC}"
            ;;
        8)
            echo -e "${BOLD}${BLUE}Question 8: Create Compressed Archive${NC}"
            echo ""
            echo "Backup /etc into /root/etc_backup.tar.bz2"
            echo ""
            echo -e "${YELLOW}Hint: tar -cjf${NC}"
            ;;
        9)
            echo -e "${BOLD}${BLUE}Question 9: Configure Chrony${NC}"
            echo ""
            echo "Configure chrony to sync with servera.lab.example.com"
            echo ""
            echo -e "${YELLOW}Hint: /etc/chrony/chrony.conf${NC}"
            ;;
        10)
            echo -e "${BOLD}${BLUE}Question 10: Find Files by Owner${NC}"
            echo ""
            echo "Find all files owned by walhalla and copy to /root/walhalla"
            echo ""
            echo -e "${YELLOW}Hint: find / -user walhalla${NC}"
            ;;
        11)
            echo -e "${BOLD}${BLUE}Question 11: Extract Strings${NC}"
            echo ""
            echo "Extract all strings containing \"nal\" from /usr/share/dict/words"
            echo ""
            echo -e "${YELLOW}Hint: grep${NC}"
            ;;
        12)
            echo -e "${BOLD}${BLUE}Question 12: Reset Root Password${NC}"
            echo ""
            echo "Practice resetting root password using rd.break method"
            echo ""
            echo -e "${YELLOW}Hint: Boot parameter, mount -o remount,rw /sysroot${NC}"
            ;;
        13)
            echo -e "${BOLD}${BLUE}Question 13: Configure Repositories (Node2)${NC}"
            echo ""
            echo "Configure repositories on Node2"
            echo ""
            echo -e "${YELLOW}Hint: Similar to Question 2${NC}"
            ;;
        14)
            echo -e "${BOLD}${BLUE}Question 14: Create LVM${NC}"
            echo ""
            echo "Create LVM with:"
            echo "  • VG: wgroup"
            echo "  • LV: wshare"
            echo "  • PE size: 8M"
            echo "  • Mount: /mnt/share"
            echo ""
            echo -e "${YELLOW}Hint: pvcreate, vgcreate -s 8M, lvcreate${NC}"
            ;;
        15)
            echo -e "${BOLD}${BLUE}Question 15: Create Swap Partition${NC}"
            echo ""
            echo "Create a 400MB swap partition"
            echo ""
            echo -e "${YELLOW}Hint: mkswap, swapon, /etc/fstab${NC}"
            ;;
        16)
            echo -e "${BOLD}${BLUE}Question 16: Resize Logical Volume${NC}"
            echo ""
            echo "Resize logical volume to approximately 450MB"
            echo ""
            echo -e "${YELLOW}Hint: lvextend, resize2fs${NC}"
            ;;
        17)
            echo -e "${BOLD}${BLUE}Question 17: Configure Tuned Profile${NC}"
            echo ""
            echo "Configure the recommended tuned profile"
            echo ""
            echo -e "${YELLOW}Hint: tuned-adm recommend, tuned-adm profile${NC}"
            ;;
        *)
            echo -e "${RED}Invalid question number${NC}"
            return 1
            ;;
    esac
}

# Main menu
show_menu() {
    local current_question=$(cat "$PROGRESS_FILE")
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Current Progress: Question $current_question of 17${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Choose an option:"
    echo ""
    echo "  [1] Start/Continue Exam (Question $((current_question + 1)))"
    echo "  [2] Jump to Specific Question"
    echo "  [3] View All Questions"
    echo "  [4] Validate Current Progress"
    echo "  [5] Reset Exam Progress"
    echo "  [6] Finish Exam"
    echo "  [7] Exit to Shell"
    echo ""
    echo -n "Enter your choice [1-7]: "
}

# Jump to question menu
jump_to_question() {
    show_header
    echo -e "${BOLD}Select a Question (1-17):${NC}"
    echo ""
    echo "  [1] Network Configuration"
    echo "  [2] DNF Repositories"
    echo "  [3] Troubleshoot httpd Service (Port 82)"
    echo "  [4] Users and Groups"
    echo "  [5] Collaborative Directory"
    echo "  [6] Cron Job"
    echo "  [7] Autofs Configuration"
    echo "  [8] Compressed Archive"
    echo "  [9] Chrony/NTP"
    echo "  [10] Find Files by Owner"
    echo "  [11] Extract Strings"
    echo "  [12] Reset Root Password"
    echo "  [13] Configure Repositories (Node2)"
    echo "  [14] Create LVM"
    echo "  [15] Create Swap Partition"
    echo "  [16] Resize Logical Volume"
    echo "  [17] Configure Tuned Profile"
    echo ""
    echo -n "Enter question number: "
    read -r question_num
    
    if [[ $question_num =~ ^[1-9]$|^1[0-7]$ ]]; then
        echo "$((question_num - 1))" > "$PROGRESS_FILE"
        show_question "$question_num"
        echo ""
        echo -n "Press Enter to continue..."
        read
    else
        echo -e "${RED}Invalid question number${NC}"
        sleep 2
    fi
}

# View all questions
view_all_questions() {
    show_header
    echo -e "${BOLD}All RHCSA Exam Questions:${NC}"
    echo ""
    cat "$QUESTIONS_FILE"
    echo ""
    echo -n "Press Enter to return to menu..."
    read
}

# Validate progress
validate_progress() {
    show_header
    echo -e "${BOLD}${CYAN}Running Validation...${NC}"
    echo ""
    
    if [[ -f /root/validate_lab.sh ]]; then
        /root/validate_lab.sh
    else
        echo -e "${YELLOW}Validation script not found${NC}"
        echo "Create /root/validate_lab.sh to check your work"
    fi
    
    echo ""
    echo -n "Press Enter to continue..."
    read
}

# Reset progress
reset_progress() {
    show_header
    echo -e "${RED}${BOLD}Reset Exam Progress?${NC}"
    echo ""
    echo "This will:"
    echo "  • Reset question progress to 0"
    echo "  • Reset the exam timer"
    echo "  • NOT reset your actual work"
    echo ""
    echo -n "Are you sure? (yes/no): "
    read -r confirm
    
    if [[ "$confirm" == "yes" ]]; then
        echo "0" > "$PROGRESS_FILE"
        echo "$(date +%s)" > "$TIMER_FILE"
        echo -e "${GREEN}Progress reset successfully${NC}"
    else
        echo "Reset cancelled"
    fi
    sleep 2
}

# Finish exam
finish_exam() {
    show_header
    echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                    EXAM COMPLETED!                             ║${NC}"
    echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local elapsed=$(get_elapsed_time)
    local elapsed_fmt=$(format_time $elapsed)
    
    echo -e "Total Time: ${BOLD}$elapsed_fmt${NC}"
    echo ""
    echo "Running final validation..."
    echo ""
    
    if [[ -f /root/validate_lab.sh ]]; then
        /root/validate_lab.sh
    fi
    
    echo ""
    echo -e "${CYAN}Thank you for using RHCSA Exam Simulator!${NC}"
    echo ""
    echo -n "Press Enter to exit..."
    read
    exit 0
}

# Continue to next question
continue_exam() {
    local current=$(cat "$PROGRESS_FILE")
    local next=$((current + 1))
    
    if [[ $next -gt 17 ]]; then
        echo -e "${GREEN}You've reached the last question!${NC}"
        sleep 2
        return
    fi
    
    show_question "$next"
    echo "$next" > "$PROGRESS_FILE"
    
    echo ""
    echo -n "Press Enter to return to menu..."
    read
}

# Main loop
main() {
    init_progress
    
    # Welcome message on first run
    if [[ $(cat "$PROGRESS_FILE") -eq 0 ]]; then
        show_header
        echo -e "${BOLD}${GREEN}Welcome to RHCSA Exam Simulator!${NC}"
        echo ""
        echo "This interactive exam will guide you through 17 RHCSA tasks."
        echo "You have 2 hours to complete all questions."
        echo ""
        echo "Features:"
        echo "  ✓ Navigate questions one by one"
        echo "  ✓ Jump to any question"
        echo "  ✓ Track your time"
        echo "  ✓ Validate your work"
        echo "  ✓ Finish anytime"
        echo ""
        echo -n "Press Enter to begin..."
        read
    fi
    
    while true; do
        show_header
        show_menu
        read -r choice
        
        case $choice in
            1) continue_exam ;;
            2) jump_to_question ;;
            3) view_all_questions ;;
            4) validate_progress ;;
            5) reset_progress ;;
            6) finish_exam ;;
            7) 
                echo ""
                echo "Exiting to shell. Run 'rhcsa-exam' to return to exam."
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run main
main

# Made with Bob
