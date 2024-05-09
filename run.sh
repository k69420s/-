#!/usr/bin/env bash
set -e

# Define the repository
GIT_DIR="/tmp/setup"
GIT_URL="https://github.com/k69420s/-.git"

function require_package () {
    local package=$1

    # Check if the package is installed
    if [ -z "$(apt list $package --installed)" ]; then
        echo "$package is not installed."

        # Check if sudo is available
        if command -v sudo &> /dev/null; then
            echo "Trying to install $package using sudo."
            sudo apt update || true
            sudo apt install -y "$package"
        else
            # Check if the script is running as root
            if [ "$(id -u)" -eq 0 ]; then
                echo "Trying to install $package as root."
                apt update || true
                apt install -y "$package"
            else
                echo "You are not root and sudo is not available. Please install $package manually."
                exit 1
            fi
        fi
    fi
}

require_package "ansible"
require_package "git"
require_package "python3-apt"
require_package "sudo"

# Check if /tmp/setup/ directory exists
if [ -d "${GIT_DIR}" ]; then
    # Check if it's a git repository
    if [ -d "${GIT_DIR}/.git" ]; then
        echo "Updating existing git repository..."
        cd "${GIT_DIR}"
        git pull
    else
        echo "Directory ${GIT_DIR} exists but is not a git repository."
        echo "Please check the directory contents and ensure it is a valid git repository."
        exit 1
    fi
else
    # Clone the repository if it doesn't exist
    echo "Cloning git repository into ${GIT_DIR}..."
    git clone "${GIT_URL}" "${GIT_DIR}"
fi

cd "${GIT_DIR}"

ansible-playbook playbook.yml --diff
