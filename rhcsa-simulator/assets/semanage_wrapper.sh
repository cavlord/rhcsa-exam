#!/bin/bash
# SELinux semanage wrapper for Ubuntu (AppArmor-based systems)
# This allows RHCSA students to practice semanage commands on Ubuntu
# without enabling SELinux

# Check if SELinux is actually enabled
if command -v getenforce >/dev/null 2>&1; then
    SELINUX_STATUS=$(getenforce 2>/dev/null || echo "Disabled")
    if [ "$SELINUX_STATUS" != "Disabled" ]; then
        # SELinux is enabled, use real semanage
        exec /usr/sbin/semanage "$@"
    fi
fi

# SELinux not enabled - provide Ubuntu alternative
echo "Note: SELinux is not enabled on this Ubuntu system."
echo "Translating semanage command to Ubuntu equivalent..."
echo ""

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
        echo "SELinux command: semanage port -a -t $TYPE -p $PROTO $PORT"
        echo ""
        echo "Ubuntu equivalent actions:"
        echo "1. Allow port in firewall:"
        echo "   sudo ufw allow $PORT/$PROTO"
        echo ""
        echo "2. Configure Apache to listen on port $PORT:"
        echo "   sudo sed -i 's/Listen [0-9]*/Listen $PORT/' /etc/apache2/ports.conf"
        echo "   sudo sed -i 's/<VirtualHost \*:[0-9]*>/<VirtualHost *:$PORT>/' /etc/apache2/sites-available/000-default.conf"
        echo ""
        echo "3. Restart Apache:"
        echo "   sudo systemctl restart apache2"
        echo ""
        echo "Executing firewall command..."
        ufw allow "$PORT/$PROTO" 2>/dev/null && echo "✓ Firewall rule added for port $PORT/$PROTO"
        echo ""
        echo "Note: You still need to manually update Apache configuration files."
        exit 0
    elif [[ "$ACTION" == "list" ]]; then
        echo "Listing allowed ports in UFW firewall:"
        ufw status | grep -E "^[0-9]"
        exit 0
    fi
fi

echo "Usage: semanage port -a -t TYPE -p PROTOCOL PORT"
echo "Example: semanage port -a -t http_port_t -p tcp 82"
echo ""
echo "This wrapper translates SELinux commands to Ubuntu equivalents."
exit 1

# Made with Bob
