#!/bin/bash

set -e

echo "=== NETLIFY BUILD: ROCKY LINUX DOCS WITH DIRECTORY-BASED VERSIONING ==="

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# FORCE cleanup
echo "Force cleaning any existing directories..."
rm -rf rockydocs3 docs site 2>/dev/null || true

# Get content
echo "Fetching documentation content..."
git clone https://github.com/wsoyinka/rockydocs3.git

# Verify clone worked
if [ ! -d "rockydocs3" ]; then
    echo "❌ Failed to clone rockydocs3 repository"
    exit 1
fi


# Force clean git state
if [ -d ".git" ]; then
    rm -rf .git
fi

git init
# Git setup for mike
echo "Setting up git configuration..."
git config user.name "wsoyinka"
git config user.email "webmaster@rockylinux.org"
git add .
git commit -m "Fresh commit for Netlify build $(date)"

echo "Building with mike versioning..."

# Function to build a specific version from a specific directory
build_version() {
    local version=$1
    local source_dir=$2
    local alias=$3
    local title=$4
    
    echo "Building Rocky Linux $version from $source_dir..."
    
    # Set up docs for this version
    rm -rf docs
    mkdir -p docs
    
    if [ -d "rockydocs3/$source_dir" ]; then
        cp -r "rockydocs3/$source_dir"/* docs/
        echo "✅ Content copied for version $version from $source_dir"
    else
        echo "❌ Directory rockydocs3/$source_dir not found!"
        echo "Available directories:"
        ls -la rockydocs3/
        return 1
    fi
    
    # Deploy with mike
    if [ -n "$alias" ] && [ -n "$title" ]; then
        mike deploy "$version" "$alias" --title="$title"
    elif [ -n "$alias" ]; then
        mike deploy "$version" "$alias"
    elif [ -n "$title" ]; then
        mike deploy "$version" --title="$title"
    else
        mike deploy "$version"
    fi
    
    echo "✅ Rocky Linux $version deployed successfully"
}

# Build each version from its respective directory
build_version "8" "rocky-8" "" ""
build_version "9" "rocky-9" "" ""
build_version "10" "main" "latest" ""

echo "Setting default version..."
mike set-default latest

echo "✅ All versions deployed successfully"

# Rest of the extraction logic...
echo "Extracting built site for Netlify..."
rm -rf site

if git show-ref --verify --quiet refs/heads/gh-pages; then
    BRANCH_FILE_COUNT=$(git ls-tree --name-only gh-pages | wc -l)
    if [ "$BRANCH_FILE_COUNT" -gt 0 ]; then
        mkdir -p site
        git archive gh-pages | tar -x -C site
        echo "✅ Site extracted successfully"
    else
        echo "❌ gh-pages branch is empty!"
        exit 1
    fi
else
    echo "❌ No gh-pages branch found!"
    exit 1
fi

echo "🎉 Build completed successfully!"
