#!/bin/bash

################################################################################
# WebPortal Systemd Service Installation Script
# This script creates a systemd service for WebPortal
# Usage: bash install-service.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    print_error "This script must be run as root or with sudo"
    exit 1
fi

# Get current user and webportal directory
CURRENT_USER=$(who | awk '{print $1}' | head -n 1)
WEBPORTAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header "WebPortal Systemd Service Installation"

print_info "Detected user: $CURRENT_USER"
print_info "WebPortal directory: $WEBPORTAL_DIR"

# Create systemd service file
print_header "Creating Systemd Service File"

SERVICE_FILE="/etc/systemd/system/webportal.service"

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=WebPortal Home Lab Dashboard
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$WEBPORTAL_DIR
Environment="PATH=$WEBPORTAL_DIR/venv/bin"
ExecStart=$WEBPORTAL_DIR/venv/bin/python3 $WEBPORTAL_DIR/app.py
Restart=always
RestartSec=10
StartLimitInterval=60s
StartLimitBurst=3
StandardOutput=journal
StandardError=journal
SyslogIdentifier=webportal

[Install]
WantedBy=multi-user.target
EOF

print_success "Service file created: $SERVICE_FILE"

# Reload systemd daemon
print_header "Reloading Systemd Daemon"
systemctl daemon-reload
print_success "Systemd daemon reloaded"

# Enable the service
print_header "Enabling WebPortal Service"
systemctl enable webportal.service
print_success "WebPortal service enabled"

# Display next steps
echo ""
print_header "Service Installation Complete!"

echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                    Systemd Service Successfully Installed!                  ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
print_header "Available Commands"
echo "Start the service:"
echo "  ${BLUE}sudo systemctl start webportal${NC}"
echo ""
echo "Stop the service:"
echo "  ${BLUE}sudo systemctl stop webportal${NC}"
echo ""
echo "Check service status:"
echo "  ${BLUE}sudo systemctl status webportal${NC}"
echo ""
echo "View service logs:"
echo "  ${BLUE}sudo journalctl -u webportal -f${NC}"
echo ""
echo "Restart the service:"
echo "  ${BLUE}sudo systemctl restart webportal${NC}"
echo ""

print_info "The service is now enabled and will start automatically on boot."
print_info "To start it immediately, run: sudo systemctl start webportal"
