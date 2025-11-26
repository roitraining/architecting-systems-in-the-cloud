#!/bin/bash

# Setup script to prepare Space Invaders for Elastic Beanstalk deployment
# This script copies the src files into the elasticbeanstalk directory structure

echo "Setting up Space Invaders for Elastic Beanstalk deployment..."

# Create public directory if it doesn't exist
mkdir -p public

# Copy all source files to public directory
echo "Copying source files to public directory..."
cp -r ../src/* public/

echo "✅ Setup complete!"
echo ""
echo "Directory structure:"
echo "elasticbeanstalk/"
echo "├── server.js          (Express server)"
echo "├── package.json       (Node.js config)"
echo "├── .ebignore         (Files to exclude)"
echo "└── public/           (Static files)"
echo "    ├── index.html"
echo "    ├── app.js"
echo "    ├── style.css"
echo "    └── ..."
echo ""
echo "Next steps:"
echo "1. Run: eb init"
echo "2. Run: eb create space-invaders-env"
echo "3. Run: eb open"
