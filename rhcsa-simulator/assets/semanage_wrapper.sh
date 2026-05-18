#!/bin/bash
# SELinux semanage wrapper for Ubuntu (AppArmor-based systems)
# This allows RHCSA students to practice semanage commands on Ubuntu
# Automatically configures Apache when adding http ports

# Check if SELinux is actually enabled
if command -v getenforce >/dev/null 2>&1; then
    SELINUX_STATUS=$(getenforce 2>/dev/null || echo "Disabled")
    if [ "$SELINUX_STATUS" != "Disabled" ]; then
        # SELinux is enabled, use real semanage
        exec /usr/sbin/semanage "$@"
    fi
fi

# Parse semanage port command
if [[ "$1" == "port" ]]; then
    ACTION=""
    PORT=""
    PROTO=""
    TYPE=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--add) ACTION="add"; shift ;;
            -d|--delete) ACTION="delete"; shift ;;
            -m|--modify) ACTION="modify"; shift ;;
            -l|--list) ACTION="list"; shift ;;
            -t) TYPE="$2"; shift 2 ;;
            -p) PROTO="$2"; shift 2 ;;
            [0-9]*) PORT="$1"; shift ;;
            *) shift ;;
        esac
    done
    
    if [[ "$ACTION" == "add" && -n "$PORT" && -n "$PROTO" ]]; then
        echo "Configuring port $PORT for $TYPE..."
        
        # 1. Allow port in firewall
        ufw allow "$PORT/$PROTO" 2>/dev/null && echo "✓ Firewall: Port $PORT/$PROTO allowed"
        
        # 2. If it's http_port_t, automatically configure Apache
        if [[ "$TYPE" == "http_port_t" ]]; then
            echo "✓ Detected http_port_t - Configuring Apache automatically..."
            
            # Update Apache ports.conf
            if [ -f /etc/apache2/ports.conf ]; then
                sed -i "s/Listen [0-9]*/Listen $PORT/" /etc/apache2/ports.conf
                echo "✓ Updated /etc/apache2/ports.conf to Listen $PORT"
            fi
            
            # Update VirtualHost in default site
            if [ -f /etc/apache2/sites-available/000-default.conf ]; then
                sed -i "s/<VirtualHost \*:[0-9]*>/<VirtualHost *:$PORT>/" /etc/apache2/sites-available/000-default.conf
                echo "✓ Updated /etc/apache2/sites-available/000-default.conf to port $PORT"
            fi
            
            # Restart Apache
            systemctl restart apache2 2>/dev/null && echo "✓ Apache restarted successfully"
            
            # Verify
            if ss -tlnp 2>/dev/null | grep -q ":$PORT.*apache2"; then
                echo "✓ Apache is now listening on port $PORT"
            else
                echo "⚠ Warning: Apache may not be listening on port $PORT yet"
            fi
        fi
        
        echo ""
        echo "✅ Port $PORT configured successfully!"
        exit 0
        
    elif [[ "$ACTION" == "list" ]]; then
        # Show real semanage output if available
        if command -v /usr/sbin/semanage >/dev/null 2>&1; then
            exec /usr/sbin/semanage port -l
        else
            echo "Listing allowed ports in UFW firewall:"
            ufw status | grep -E "^[0-9]"
        fi
        exit 0
    fi
fi

echo "Usage: semanage port -a -t TYPE -p PROTOCOL PORT"
echo "Example: semanage port -a -t http_port_t -p tcp 82"
exit 1

# Made with Bob
