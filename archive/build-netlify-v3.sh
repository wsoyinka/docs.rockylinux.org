#!/bin/bash

set -e

echo "=== NETLIFY BUILD: ROCKY LINUX DOCS WITH MIKE ==="

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Get content - handle existing directory
echo "Fetching documentation content..."
if [ -d "rockydocs3" ]; then
    echo "rockydocs3 directory exists, removing and re-cloning..."
    rm -rf rockydocs3
fi

git clone https://github.com/wsoyinka/rockydocs3.git

# Set up content structure
echo "Setting up documentation structure..."
rm -rf docs
mkdir -p docs
cp -r rockydocs3/docs/* docs/

# Git setup for mike (Netlify environment)
echo "Setting up git configuration..."
git config user.name "Netlify Build"
git config user.email "build@netlify.com"

# Initialize git if needed (shouldn't be needed on Netlify, but safety check)
if [ ! -d ".git" ]; then
    git init
fi

# Commit current content
echo "Committing content for mike..."
git add -A
git commit -m "Update content for Netlify build $(date)" || echo "No changes to commit"

echo "Building with mike versioning..."

# Deploy versions
echo "Deploying Rocky Linux 8..."
mike deploy 8 

echo "Deploying Rocky Linux 9..."
mike deploy 9

echo "Deploying Rocky Linux 10..."
mike deploy 10 latest

echo "Setting default version..."
mike set-default latest

echo "Extracting built site for Netlify..."

# Clean any existing site directory
rm -rf site

# Extract from gh-pages for Netlify
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "gh-pages branch found, checking content..."
    
    if [ "$(git ls-tree --name-only gh-pages | wc -l)" -gt 0 ]; then
        echo "Extracting site content from gh-pages..."
        
        # Create temporary directory for extraction
        TEMP_EXTRACT=$(mktemp -d)
        echo "Using temporary directory: $TEMP_EXTRACT"
        
        # Extract using git archive (most reliable for Netlify)
        git archive gh-pages | tar -x -C "$TEMP_EXTRACT"
        
        # Move extracted content to site directory
        mv "$TEMP_EXTRACT" site
        
        # Verify extraction worked 
        if [ -d "site" ] && [ "$(ls -A site 2>/dev/null | wc -l)" -gt 0 ]; then
            echo "✅ Site extracted successfully"
            echo "Site contents:"
            ls -la site/ | head -10
        else
            echo "❌ Site extraction failed - empty or missing directory"
            exit 1
        fi
    else
        echo "❌ gh-pages branch is empty!"
        echo "Available branches:"
        git branch -a
        exit 1
    fi
else
    echo "❌ No gh-pages branch found!"
    echo "Available branches:"
    git branch -a
    exit 1
fi

echo ""
echo "Build completed successfully!"
echo "Available versions:"
mike list || echo "Failed to list versions"

echo ""
echo "Final site structure:"
ls -la site/ 2>/dev/null | head -10 || echo "Cannot list site directory"

echo ""
echo "✅ Site ready for Netlify deployment from site/ directory"
