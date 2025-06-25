#!/bin/bash

set -e  # Exit on any error

echo "Starting Rocky Linux Documentation Build..."

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Clone or update the content repository
echo "Fetching documentation content..."
if [ -d "rockydocs3" ]; then
    echo "Content directory exists, updating..."
    cd rockydocs3
    git pull origin main
    cd ..
else
    echo "Cloning content repository..."
    git clone https://github.com/wsoyinka/rockydocs3.git
fi

# Set up content structure
echo "Setting up documentation structure..."
rm -rf docs
mkdir -p docs

# Copy content from rockydocs3/docs to docs/
if [ -d "rockydocs3/docs" ]; then
    cp -r rockydocs3/docs/* docs/
    echo "Copied content from rockydocs3/docs/"
    echo "Content files found:"
    find docs -name "*.md" | head -10
else
    echo "Error: rockydocs3/docs directory not found!"
    echo "Available directories in rockydocs3:"
    ls -la rockydocs3/
    exit 1
fi

# Initialize git repo if needed
#if [ ! -d ".git" ]; then
#    git init
#    git config user.name "Netlify Build" 
#    git config user.email "build@netlify.com"
#fi


git config  --global user.name wsoyinka
git config  --global user.email webmaster@rockylinux.org

# Add and commit current state for mike
git add -A
git commit -m "Update content for mike versioning" || echo "No changes to commit"

echo "Building documentation versions with mike..."

# Deploy version 8
echo "Deploying Rocky Linux 8..."
mike deploy 8

# Deploy version 9
echo "Deploying Rocky Linux 9..."
mike deploy 9

# Deploy version 10 as latest
echo "Deploying Rocky Linux 10 (Latest)..."
mike deploy 10 latest

# Set latest as default
echo "Setting default version..."
mike set-default latest

# Build static site by serving the gh-pages content
echo "Generating static site..."

# Check if gh-pages branch exists and extract content
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "Extracting site from gh-pages branch..."
    
    # Create site directory from gh-pages branch
    rm -rf site
    git worktree add site gh-pages 2>/dev/null || {
        # If worktree fails, use archive method
        mkdir -p site
        git archive gh-pages | tar -x -C site
    }
    
    echo "Site extracted successfully!"
else
    echo "Warning: gh-pages branch not found. Creating basic site structure..."
    mkdir -p site
    echo "<h1>Mike versioning setup complete</h1>" > site/index.html
fi

echo "Build completed successfully!"
echo ""
echo "Site directory contents:"
ls -la site/ 2>/dev/null || echo "Site directory not accessible"
echo ""
echo "Available versions:"
mike list
echo ""
echo "To serve locally, run: mike serve"
