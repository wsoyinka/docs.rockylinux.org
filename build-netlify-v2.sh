#!/bin/bash

set -e

echo "=== NETLIFY BUILD: ROCKY LINUX DOCS WITH MIKE ==="

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Get content
echo "Fetching documentation content..."
git clone https://github.com/wsoyinka/rockydocs3.git

# Set up content structure
echo "Setting up documentation structure..."
rm -rf docs
mkdir -p docs
cp -r rockydocs3/docs/* docs/

# Git setup for mike (Netlify environment)
git config user.name "Netlify Build"
git config user.email "build@netlify.com"

# Commit current content
git add -A
git commit -m "Update content for Netlify build" || echo "No changes to commit"

echo "Building with mike versioning..."

# Deploy versions
mike deploy 8 rocky8 --title="Rocky Linux 8"
mike deploy 9 rocky9 --title="Rocky Linux 9"
mike deploy 10 latest --title="Rocky Linux 10 (Latest)"
mike set-default latest

echo "Extracting built site for Netlify..."

# Extract from gh-pages for Netlify
if git show-ref --verify --quiet refs/heads/gh-pages; then
    if [ "$(git ls-tree --name-only gh-pages | wc -l)" -gt 0 ]; then
        # Use git archive for Netlify (more reliable than checkout)
        git archive gh-pages | tar -x
        
        # Move extracted files to site directory
        mkdir -p site
        # Move all files except .git to site/
        find . -maxdepth 1 ! -name . ! -name .. ! -name .git ! -name site -exec mv {} site/ \;
        
        echo "✅ Site extracted for Netlify deployment"
    else
        echo "❌ gh-pages branch is empty!"
        exit 1
    fi
else
    echo "❌ No gh-pages branch found!"
    exit 1
fi

echo "Available versions:"
mike list

echo "Site ready for Netlify deployment from site/ directory"