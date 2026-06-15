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
    
    # Get the current directory
    INITIAL_DIR=$(pwd)
    
    if [ -d "webportal" ]; then
        print_info "WebPortal directory already exists"
        read -p "Do you want to update it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd webportal
            git pull origin main
            print_success "Repository updated"
        else
            cd webportal
            print_info "Using existing repository"
        fi
    else
        print_info "Cloning WebPortal repository..."
        git clone https://github.com/nikkosojasun/webportal.git
        cd webportal
        print_success "Repository cloned"
    fi
    
    # Export the webportal directory path for use in other functions
    export WEBPORTAL_DIR=$(pwd)
    print_info "Working directory: $WEBPORTAL_DIR"
}

# Create virtual environment
setup_venv() {
    print_header "Setting Up Python Virtual Environment"
    
    # Ensure we're in the webportal directory
    if [ -z "$WEBPORTAL_DIR" ]; then
        WEBPORTAL_DIR=$(pwd)
    fi
    
    cd "$WEBPORTAL_DIR"
    
    # Check if venv directory exists
    if [ -d "venv" ]; then
        # Check if the virtual environment is valid
        if [ ! -f "venv/bin/activate" ] || [ ! -f "venv/bin/python" ]; then
            print_warning "Virtual environment exists but appears to be corrupted"
            read -p "Do you want to remove and recreate it? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_info "Removing corrupted virtual environment..."
                rm -rf venv
                print_success "Removed venv directory"
                print_info "Creating new virtual environment..."
                python3 -m venv venv
                print_success "Virtual environment created"
            else
                print_error "Cannot proceed with corrupted virtual environment"
                exit 1
            fi
        else
            print_info "Virtual environment already exists and appears valid"
        fi
    else
        print_info "Creating virtual environment..."
        python3 -m venv venv
        print_success "Virtual environment created"
    fi
    
    # Verify the virtual environment can be activated
    if [ ! -f "venv/bin/activate" ]; then
        print_error "Failed to create virtual environment properly"
        print_info "Attempting to recreate..."
        rm -rf venv
        python3 -m venv venv
        if [ ! -f "venv/bin/activate" ]; then
            print_error "Failed to create virtual environment. Check your Python installation"
            exit 1
        fi
    fi
    
    print_info "Activating virtual environment..."
    source venv/bin/activate
    print_success "Virtual environment activated"
}

# Install Python dependencies
install_dependencies() {
    print_header "Installing Python Dependencies"
    
    # Ensure we're in the webportal directory
    if [ -z "$WEBPORTAL_DIR" ]; then
        WEBPORTAL_DIR=$(pwd)
    fi
    
    cd "$WEBPORTAL_DIR"
    
    # Ensure we're in the virtual environment
    if [ -z "$VIRTUAL_ENV" ]; then
        print_warning "Virtual environment not active, activating now..."
        source venv/bin/activate
    fi
    
    print_info "Upgrading pip, setuptools, and wheel..."
    pip install --upgrade pip setuptools wheel
    
    print_info "Installing requirements from requirements.txt..."
    pip install -r requirements.txt
    
    print_success "All dependencies installed successfully"
}

# Test installation
test_installation() {
    print_header "Testing Installation"
    
    # Ensure we're in the webportal directory
    if [ -z "$WEBPORTAL_DIR" ]; then
        WEBPORTAL_DIR=$(pwd)
    fi
    
    cd "$WEBPORTAL_DIR"
    
    # Ensure we're in the virtual environment
    if [ -z "$VIRTUAL_ENV" ]; then
        print_warning "Virtual environment not active, activating now..."
        source venv/bin/activate
    fi
    
    print_info "Verifying Python packages..."
    python -c "import flask; print(f'Flask version: {flask.__version__}')" || print_warning "Flask not found yet"
    python -c "import yaml; print(f'PyYAML version: {yaml.__version__}')" || print_warning "PyYAML not found yet"
    python -c "from werkzeug import __version__; print(f'Werkzeug version: {__version__}')" || print_warning "Werkzeug not found yet"
    
    print_success "Package verification complete"
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

# Create activation helper script
create_activation_script() {
    print_header "Creating Activation Helper Script"
    
    # Ensure we're in the webportal directory
    if [ -z "$WEBPORTAL_DIR" ]; then
        WEBPORTAL_DIR=$(pwd)
    fi
    
    cd "$WEBPORTAL_DIR"
    
    # Create a helper script that can be sourced
    cat > activate.sh << 'HELPER_SCRIPT'
#!/bin/bash
# WebPortal Activation Helper Script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/venv/bin/activate"
echo "WebPortal virtual environment activated!"
echo "You are now in: $VIRTUAL_ENV"
HELPER_SCRIPT
    
    chmod +x activate.sh
    print_success "Created activate.sh helper script"
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
    print_info "WebPortal installed at: $WEBPORTAL_DIR"
    
    echo ""
    print_header "Quick Start - Option 1 (Using Helper Script)"
    echo "From any directory, activate with:"
    echo "   ${BLUE}source $WEBPORTAL_DIR/activate.sh${NC}"
    echo ""
    echo "Then run:"
    echo "   ${BLUE}python3 app.py${NC}"
    echo ""
    
    echo ""
    print_header "Quick Start - Option 2 (Manual Activation)"
    echo "1. Navigate to the webportal directory:"
    echo "   ${BLUE}cd $WEBPORTAL_DIR${NC}"
    echo ""
    echo "2. Activate virtual environment:"
    echo "   ${BLUE}source venv/bin/activate${NC}"
    echo ""
    echo "3. Run the application:"
    echo "   ${BLUE}python3 app.py${NC}"
    echo ""
    echo "4. Open your browser and navigate to:"
    echo "   ${BLUE}http://localhost:5000${NC}"
    echo ""
    
    echo -e "${YELLOW}Optional: Run as a systemd service${NC}"
    echo "For persistent background operation:"
    echo "   ${BLUE}cd $WEBPORTAL_DIR && sudo bash install-service.sh${NC}"
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
    create_activation_script
    show_next_steps
}

# Run main function
main "$@"
