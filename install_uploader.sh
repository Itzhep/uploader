#!/bin/bash

# Function to check and install curl
install_curl() {
    if ! command -v curl &> /dev/null; then
        echo "curl is not installed. Installing..."
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y curl
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y curl
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y curl
        else
            echo "Package manager not found. Please install curl manually."
            exit 1
        fi
    else
        echo "curl is already installed."
    fi
}

# Function to create the ~/bin directory if it doesn't exist
create_bin_directory() {
    if [ ! -d "$HOME/bin" ]; then
        mkdir -p "$HOME/bin"
        echo "Created $HOME/bin directory."
    fi
}

# Function to copy the uploader script
install_script() {
    SCRIPT_SOURCE="file_uploader.sh"
    SCRIPT_DEST="$HOME/bin/upload"

    if [ -f "$SCRIPT_SOURCE" ]; then
        cp "$SCRIPT_SOURCE" "$SCRIPT_DEST"
        chmod +x "$SCRIPT_DEST"
        echo "Installed uploader script as 'upload' command."
    else
        echo "Error: $SCRIPT_SOURCE not found. Please ensure it is in the current directory."
        exit 1
    fi
}

# Function to update PATH (if ~/bin is not in PATH)
update_path() {
    if ! echo "$PATH" | grep -q "$HOME/bin"; then
        echo "Adding $HOME/bin to PATH..."
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
        echo "$HOME/bin added to PATH."
    else
        echo "$HOME/bin is already in PATH."
    fi
}

# Main installation process
echo "Starting installation of file uploader tool..."

install_curl
create_bin_directory
install_script
update_path

echo "Installation completed successfully!"
clear
upload
