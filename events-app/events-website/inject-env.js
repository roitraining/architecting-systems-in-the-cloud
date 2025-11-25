// Inject environment variables into the HTML
const fs = require('fs');
const path = require('path');

const API_URL = process.env.API_URL || 'http://localhost:3001';

// Read the index.html template
let html = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');

// Inject the API_URL as a global variable
const scriptTag = `<script>window.API_URL = '${API_URL}';</script>`;
html = html.replace('</head>', `${scriptTag}\n</head>`);

// Write the modified HTML
fs.writeFileSync(path.join(__dirname, 'index-generated.html'), html);

console.log(`Injected API_URL: ${API_URL}`);