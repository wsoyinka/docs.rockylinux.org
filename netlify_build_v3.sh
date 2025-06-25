#!/bin/bash

set -e

echo "=== NETLIFY BUILD: ROCKY LINUX DOCS WITH MIKE ==="

# Debug: Show current directory and contents
echo "Current directory: $(pwd)"
echo "Contents before cleanup:"
ls -la

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# FORCE cleanup of any existing content
echo "Force cleaning any existing directories..."
rm -rf rockydocs3 docs site 2>/dev/null || true

# Double-check cleanup worked
echo "Contents after cleanup:"
ls -la

# Get content with force flag
echo "Fetching documentation content..."
git clone https://github.com/wsoyinka/rockydocs3.git

# Verify clone worked
if [ ! -d "rockydocs3" ]; then
    echo "❌ Failed to clone rockydocs3 repository"
    exit 1
fi

echo "Successfully cloned rockydocs3"
ls -la rockydocs3/

# Set up content structure
echo "Setting up documentation structure..."
mkdir -p docs

# Verify source exists before copying
if [ ! -d "rockydocs3/docs" ]; then
    echo "❌ rockydocs3/docs directory not found!"
    echo "Available directories in rockydocs3:"
    ls -la rockydocs3/
    exit 1
fi

cp -r rockydocs3/docs/* docs/
echo "✅ Content copied successfully"

# Git setup for mike (Netlify environment)
echo "Setting up git configuration..."
git config user.name "Netlify Build"
git config user.email "build@netlify.com"

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit for mike"
fi

# Commit current content
echo "Committing content for mike..."
git add -A
git commit -m "Update content for Netlify build $(date)" || {
    echo "No changes to commit, continuing..."
}

echo "Building with mike versioning..."

# Deploy versions with verbose output
echo "Deploying Rocky Linux 8..."
mike deploy 8  || {
    echo "❌ Failed to deploy version 8"
    exit 1
}

echo "Deploying Rocky Linux 9..."
mike deploy 9  || {
    echo "❌ Failed to deploy version 9"
    exit 1
}

echo "Deploying Rocky Linux 10..."
mike deploy 10 latest  || {
    echo "❌ Failed to deploy version 10"
    exit 1
}

echo "Setting default version..."
mike set-default latest || {
    echo "❌ Failed to set default version"
    exit 1
}

echo "✅ All versions deployed successfully"

# Verify mike state
echo "Verifying mike deployment..."
mike list || {
    echo "❌ Mike list failed"
    exit 1
}

echo "Extracting built site for Netlify..."

# Clean any existing site directory
rm -rf site

# Check git branches
echo "Available git branches:"
git branch -a

# Extract from gh-pages for Netlify
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "✅ gh-pages branch found"
    
    # Check if gh-pages has content
    BRANCH_FILE_COUNT=$(git ls-tree --name-only gh-pages | wc -l)
    echo "Files in gh-pages branch: $BRANCH_FILE_COUNT"
    
    if [ "$BRANCH_FILE_COUNT" -gt 0 ]; then
        echo "Extracting site content from gh-pages..."
        
        # Create site directory
        mkdir -p site
        
        # Extract using git archive
        git archive gh-pages | tar -x -C site || {
            echo "❌ Failed to extract from gh-pages"
            exit 1
        }
        
        # Verify extraction worked 
        if [ -d "site" ] && [ "$(ls -A site 2>/dev/null | wc -l)" -gt 0 ]; then
            echo "✅ Site extracted successfully"
            echo "Site directory contents:"
            ls -la site/ | head -10
            
            # Check for expected version directories
            echo "Checking for version directories:"
            ls -la site/ | grep -E "^d.*[0-9]|latest" || echo "No version directories found"
            
        else
            echo "❌ Site extraction failed - empty or missing directory"
            exit 1
        fi
    else
        echo "❌ gh-pages branch is empty!"
        echo "Last few commits on gh-pages:"
        git log --oneline gh-pages -5 || echo "No commits in gh-pages"
        exit 1
    fi
else
    echo "❌ No gh-pages branch found!"
    echo "Available branches:"
    git branch -a
    exit 1
fi

echo ""
echo "🎉 Build completed successfully!"
echo ""
echo "Final verification:"
echo "- Site directory exists: $([ -d site ] && echo 'YES' || echo 'NO')"
echo "- Site has content: $([ -n "$(ls -A site 2>/dev/null)" ] && echo 'YES' || echo 'NO')"
echo "- Version directories: $(find site -maxdepth 1 -type d -name '[0-9]*' | wc -l)"
echo ""
echo "✅ Ready for Netlify deployment!"
