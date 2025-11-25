const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files
app.use(express.static('.'));

// Proxy API requests to backend
app.use('/api-proxy', createProxyMiddleware({
  target: 'http://events-backend-service:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/api-proxy': ''
  }
}));

// Serve index.html for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Frontend server with proxy running on port ${PORT}`);
});