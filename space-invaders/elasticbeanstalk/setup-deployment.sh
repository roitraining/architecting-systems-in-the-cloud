#!/bin/bash

# Setup script to prepare Space Invaders for Elastic Beanstalk deployment
# This script copies the src files into the elasticbeanstalk directory structure

echo "========================================="
echo "Space Invaders - Elastic Beanstalk Setup"
echo "========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "server.js" ]; then
    echo "❌ Error: server.js not found!"
    echo "Please run this script from the elasticbeanstalk directory:"
    echo "  cd space-invaders/elasticbeanstalk"
    echo "  ./setup-deployment.sh"
    exit 1
fi

# Check if src directory exists
if [ ! -d "../src" ]; then
    echo "❌ Error: ../src directory not found!"
    echo "Make sure you're in the elasticbeanstalk directory and src exists"
    exit 1
fi

# Remove old public directory if it exists
if [ -d "public" ]; then
    echo "🗑️  Removing old public directory..."
    rm -rf public
fi

# Create public directory
echo "📁 Creating public directory..."
mkdir -p public

# Copy all source files to public directory
echo "📋 Copying source files to public directory..."
cp -r ../src/* public/

# Verify files were copied
if [ ! -f "public/index.html" ]; then
    echo "❌ Error: Files were not copied correctly!"
    echo "public/index.html not found"
    exit 1
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📁 Directory structure:"
echo "elasticbeanstalk/"
echo "├── server.js          (Express server)"
echo "├── package.json       (Node.js config)"
echo "├── .ebignore         (Files to exclude)"
echo "└── public/           (Static files - READY FOR DEPLOYMENT)"
echo "    ├── index.html"
echo "    ├── app.js"
echo "    ├── style.css"
echo "    ├── controllers/"
echo "    ├── views/"
echo "    └── *.svg (game assets)"
echo ""
echo "📊 Files copied:"
ls -1 public/ | wc -l | xargs echo "   "
echo ""
echo "🚀 Next steps:"
echo "1. Run: eb init"
echo "2. Run: eb create space-invaders-env"
echo "3. Run: eb open"
echo ""
echo "⚠️  IMPORTANT: The public/ directory must exist before deploying!"
echo "   If you make changes to ../src, run this script again."
