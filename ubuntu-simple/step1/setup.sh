#!/bin/bash

# Wait for system to be ready
sleep 2

# Fix line endings for all scripts (convert CRLF to LF)
cd /root
for file in *.sh; do
    [ -f "$file" ] && sed -i 's/\r$//' "$file"
done

# Make scripts executable
chmod +x /root/*.sh

# Run the lab setup (menu will be launched from within setup_lab_ubuntu.sh)
bash ./setup_lab_ubuntu.sh
