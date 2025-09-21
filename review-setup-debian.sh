#!/bin/bash

# Re:VIEW Setup Script for Debian GNU/Linux
# 
# Usage: ./review-setup-debian [COMMAND] [OPTIONS]

set -e

SCRIPT_NAME=$(basename "$0")

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if package is installed
package_installed() {
    dpkg -s "$1" &> /dev/null
}

# Task 1: Install Debian packages
task_install_packages() {
    log_info "Starting Debian package installation"
    
    # Check if running on Debian GNU/Linux
    if [[ ! -f /etc/debian_version ]]; then
        log_error "This script is designed for Debian GNU/Linux only."
        exit 1
    fi
    
    log_info "Installing bundler, texlive-lang-japanese, texlive-pictures"
    log_info "This may require your sudo password"
    
    sudo apt-get update
    sudo apt-get install -y \
        bundler \
        texlive-lang-japanese \
        texlive-latex-extra \
        texlive-pictures
    
    log_info "Package installation completed"
}

# Task 2: Install Ruby dependencies
task_bundle_install() {
    log_info "Starting Ruby dependency installation"
    
    # Check for Gemfile
    if [[ ! -f "Gemfile" ]]; then
        log_error "Gemfile not found. Please run this command in your project directory."
        exit 1
    fi
    
    # Check if bundler is installed
    if ! command_exists bundle; then
        log_error "bundler is not installed. Please run 'install-packages' first."
        exit 1
    fi
    
    log_info "Running bundle install"
    bundle install
    
    log_info "Ruby dependency installation completed"
}

# Task 3: Configure Japanese fonts
task_setup_fonts() {
    local font_family="${1:-haranoaji}"
    
    log_info "Starting Japanese font configuration"
    
    # Check if texlive-lang-japanese is installed
    if ! package_installed texlive-lang-japanese; then
        log_error "texlive-lang-japanese is not installed."
        log_error "Please run '$SCRIPT_NAME install-packages' first."
        exit 1
    fi
    
    # Check if kanji-config-updmap is available
    if ! command_exists kanji-config-updmap; then
        log_error "kanji-config-updmap not found even though texlive-lang-japanese is installed."
        log_error "This might be a system configuration issue."
        exit 1
    fi
    
    # Display current font configuration
    log_info "Current font configuration:"
    kanji-config-updmap status
    
    log_info "Setting up font: $font_family with JIS2004 encoding"
    log_info "This may require your sudo password"
    
    if ! sudo kanji-config-updmap-sys --jis2004 "$font_family"; then
        log_error "Failed to configure font: $font_family"
        log_error "Please check if the font family name is correct"
        exit 1
    fi
    
    # Display updated configuration
    log_info "Updated font configuration:"
    kanji-config-updmap status
    
    log_info "Japanese font configuration completed"
}

# Task 4: Initialize Re:VIEW project
task_review_init() {
    local project_dir="${1:-example}"
    
    log_info "Starting Re:VIEW project initialization for directory: $project_dir"
    
    # Check if bundler is installed
    if ! command_exists bundle; then
        log_error "bundler is not installed. Please run 'install-packages' first."
        exit 1
    fi
    
    log_info "Running: bundle exec review init $project_dir"
    
    # Try to run review init and handle failure
    if ! bundle exec review init "$project_dir"; then
        log_error "Failed to initialize Re:VIEW project"
        log_error "Please run 'bundle-install' first to install Re:VIEW dependencies"
        exit 1
    fi
    
    log_info "Re:VIEW project initialization completed"
    log_info "Project created in: $project_dir"
}

# Combined task: System setup (packages + bundle install + fonts)
task_system_setup() {
    log_info "Starting system setup (package installation + bundle install + fonts)"
    
    # Run install-packages
    task_install_packages
    
    # Run bundle install
    task_bundle_install
    
    # Run setup-fonts with default (haranoaji)
    log_info "Setting up Japanese fonts"
    task_setup_fonts
    
    log_info "System setup completed"
    log_info "Re:VIEW environment is ready. You can now run 'review-init' to create a project."
}

# Combined task: Full setup (packages + bundle install + fonts + review init)
task_full_setup() {
    local project_dir="${1:-example}"
    
    log_info "Starting full setup (package installation + bundle install + fonts + review init)"
    log_info "Project directory: $project_dir"
    
    # Run install-packages
    task_install_packages
    
    # Run bundle install
    task_bundle_install
    
    # Run setup-fonts with default (haranoaji)
    log_info "Setting up Japanese fonts"
    task_setup_fonts
    
    # Run review init
    log_info "Initializing Re:VIEW project"
    if ! bundle exec review init "$project_dir"; then
        log_error "Failed to initialize Re:VIEW project"
        exit 1
    fi
    
    log_info "Full setup completed"
    log_info "Project created in: $project_dir"
    log_info "You can now cd into '$project_dir' and start writing your book!"
}

# Display help message
show_help() {
    cat << EOF
Re:VIEW Setup Script for Debian GNU/Linux

Usage:
    $SCRIPT_NAME [COMMAND] [OPTIONS]

Commands:
    install-packages      Install Debian packages (bundler, texlive-lang-japanese, texlive-pictures)
                         * Requires sudo password
    
    bundle-install       Run bundle install to install Ruby dependencies
    
    setup-fonts [font]   Configure Japanese fonts
                         * Default: haranoaji (Harano Aji fonts)
                         * Optional: specify any available font family
                         * Requires texlive-lang-japanese to be installed
                         * Requires sudo password
    
    review-init [dir]    Initialize a new Re:VIEW project in the specified directory
                         * Default: example
                         * Optional: specify any directory name
    
    full-setup [dir]     Run full setup (install-packages + bundle-install + setup-fonts + review-init)
                         * Default project directory: example
                         * Optional: specify any directory name
                         * Uses default font (haranoaji)
                         * Requires sudo password
    
    help                 Display this help message

Examples:
    # Individual task execution
    $SCRIPT_NAME install-packages
    $SCRIPT_NAME bundle-install
    $SCRIPT_NAME setup-fonts                    # Use default haranoaji font
    $SCRIPT_NAME setup-fonts ipaex              # Use IPAex font
    $SCRIPT_NAME review-init                    # Create project in 'example' directory
    $SCRIPT_NAME review-init my-book            # Create project in 'my-book' directory
    
    # Full setup (everything at once)
    $SCRIPT_NAME full-setup                     # Setup with 'example' directory
    $SCRIPT_NAME full-setup my-book            # Setup with 'my-book' directory

Available Fonts:
    Common font families for setup-fonts command:
    - haranoaji   : Harano Aji fonts (default, recommended)
    - ipaex       : IPAex fonts
    - ipa         : IPA fonts
    - noto-cjk    : Noto CJK fonts (if installed)
    - noto        : Noto fonts (if installed)
    
    Run 'setup-fonts' to see all available fonts on your system.

Notes:
    - This script is designed specifically for Debian GNU/Linux
    - Commands requiring system changes will use sudo
    - You may be prompted for your sudo password
    - Run the script in your project directory (where Gemfile exists)

EOF
}

# Main function
main() {
    case "${1:-}" in
        install-packages)
            task_install_packages
            ;;
        bundle-install)
            task_bundle_install
            ;;
        setup-fonts)
            shift
            task_setup_fonts "$@"
            ;;
        review-init)
            shift
            task_review_init "$@"
            ;;
        system-setup)
            task_system_setup
            ;;
        full-setup)
            shift
            task_full_setup "$@"
            ;;
        help)
            show_help
            ;;
        "")
            log_error "No command specified"
            echo
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Execute the script
main "$@"
