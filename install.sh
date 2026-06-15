#!/bin/bash

################################################################################
# WebPortal Installation Script
# This script automates the complete installation of WebPortal on Ubuntu Server
# Usage: bash install.sh
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running on Ubuntu
check_os() {
    print_header "Checking Operating System"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [[ "$ID" == "ubuntu" ]] || [[ "$ID_LIKE" == *"ubuntu"* ]]; then
                print_success "Ubuntu detected: $PRETTY_NAME"
            else
                print_warning "This script is optimized for Ubuntu. Your system: $PRETTY_NAME"
                read -p "Continue anyway? (y/n) " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    print_error "Installation cancelled"
                    exit 1
                fi
            fi
        fi
    else
        print_error "This script requires Linux. Your OS: $OSTYPE"
        exit 1
    fi
}

# Check Python installation
check_python() {
    print_header "Checking Python Installation"
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        print_info "Installing Python 3..."
        sudo apt-get update
        sudo apt-get install -y python3 python3-dev python3-pip
        print_success "Python 3 installed"
    else
        PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
        print_success "Python 3 found: $PYTHON_VERSION"
    fi
    
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is not installed"
        print_info "Installing pip3..."
        sudo apt-get install -y python3-pip
        print_success "pip3 installed"
    else
        PIP_VERSION=$(pip3 --version | awk '{print $2}')
        print_success "pip3 found: $PIP_VERSION"
    fi
}

# Check Git installation
check_git() {
    print_header "Checking Git Installation"
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        print_info "Installing Git..."
        sudo apt-get install -y git
        print_success "Git installed"
    else
        GIT_VERSION=$(git --version | awk '{print $3}')
        print_success "Git found: $GIT_VERSION"
    fi
}

# Update system
update_system() {
    print_header "Updating System Packages"
    print_info "Running: sudo apt-get update && sudo apt-get upgrade -y"
    sudo apt-get update
    sudo apt-get upgrade -y
    print_success "System packages updated"
}

# Clone or update repository
setup_repository() {
    print_header "Setting Up Repository"
    
    if [ -d "webportal" ]; then
        print_info "WebPortal directory already exists"
        read -p "Do you want to update it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd webportal
            git pull origin main
            print_success "Repository updated"
        fi
    else
        print_info "Cloning WebPortal repository..."
        git clone https://github.com/nikkosojasun/webportal.git
        cd webportal
        print_success "Repository cloned"
    fi
}

# Create virtual environment
setup_venv() {
    print_header "Setting Up Python Virtual Environment"
    
    if [ ! -d "venv" ]; then
        print_info "Creating virtual environment..."
        python3 -m venv venv
        print_success "Virtual environment created"
    else
        print_warning "Virtual environment already exists"
    fi
    
    print_info "Activating virtual environment..."
    source venv/bin/activate
    print_success "Virtual environment activated"
}

# Install Python dependencies
install_dependencies() {
    print_header "Installing Python Dependencies"
    
    print_info "Upgrading pip, setuptools, and wheel..."
    pip install --upgrade pip setuptools wheel
    
    print_info "Installing requirements from requirements.txt..."
    pip install -r requirements.txt
    
    print_success "All dependencies installed successfully"
}

# Test installation
test_installation() {
    print_header "Testing Installation"
    
    print_info "Verifying Python packages..."
    python3 -c "import flask; print(f'Flask version: {flask.__version__}')"
    python3 -c "import yaml; print(f'PyYAML version: {yaml.__version__}')"
    python3 -c "from werkzeug import __version__; print(f'Werkzeug version: {__version__}')"
    
    print_success "All packages verified"
}

# Create configuration directory
setup_config() {
    print_header "Setting Up Configuration Directory"
    
    CONFIG_DIR="$HOME/.webportal"
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        print_success "Configuration directory created: $CONFIG_DIR"
    else
        print_info "Configuration directory already exists: $CONFIG_DIR"
    fi
}

# Display next steps
show_next_steps() {
    print_header "Installation Complete!"
    
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                    WebPortal Successfully Installed!                        ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    print_info "Configuration will be stored at: $HOME/.webportal/config.yaml"
    
    echo ""
    print_header "Quick Start"
    echo "1. Activate virtual environment:"
    echo "   ${BLUE}source venv/bin/activate${NC}"
    echo ""
    echo "2. Run the application:"
    echo "   ${BLUE}python3 app.py${NC}"
    echo ""
    echo "3. Open your browser and navigate to:"
    echo "   ${BLUE}http://localhost:5000${NC}"
    echo ""
    
    echo -e "${YELLOW}Optional: Run as a systemd service${NC}"
    echo "For persistent background operation, see the README.md file"
    echo "or run: bash install-service.sh"
    echo ""
    
    print_success "Installation is complete. Happy labbing!"
}

# Main installation flow
main() {
    print_header "WebPortal Installation Script"
    
    echo "This script will install WebPortal and all its dependencies."
    echo "It requires sudo access for package installation."
    echo ""
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
    
    check_os
    check_python
    check_git
    update_system
    setup_repository
    setup_venv
    install_dependencies
    test_installation
    setup_config
    show_next_steps
}

# Run main function
main "$@"
