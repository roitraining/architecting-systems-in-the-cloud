# Public Directory

This directory contains all the Space Invaders game files that will be served by the Express server.

## Contents

- `index.html` - Main game page
- `app.js` - AngularJS application logic
- `style.css` - Game styling
- `controllers/` - AngularJS controllers
- `views/` - HTML templates
- `*.svg` - Game assets (hero, enemies, missiles, etc.)

## Important

**Do not delete this directory!** It is required for the application to work.

The Express server (`server.js`) serves these static files when the application runs on Elastic Beanstalk.

## For Students

If you're deploying to Elastic Beanstalk, this directory should already exist with all files. If it's missing or empty, re-clone the repository from GitHub.
