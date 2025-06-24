#!/bin/bash

set -e  # Exit on any error

echo "Starting Rocky Linux Documentation Build..."

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

git submodule update --init --recursive


git config  --global user.name wsoyinak
git config  --global user.email webmaster@rockylinux.org
pip3 install --no-cache-dir -r requirements.txt
mike deploy -F mkdocs.yml 8 --update-aliases
mike deploy -F mkdocs.yml 9 --update-aliases
mike deploy -F mkdocs.yml 10 latest --update-aliases
mike set-default latest


echo "Done All"
