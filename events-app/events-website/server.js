const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const API_URL = process.env.API_URL || 'http://events-backend-service:3001';

// Serve static files
app.use(express.static(__dirname));

// Proxy API requests to backend
app.use('/api', createProxyMiddleware({
    target: API_URL,
    changeOrigin: true,
    pathRewrite: {
        '^/api': '/api'
    }
}));

// Proxy health check
app.use('/health', createProxyMiddleware({
    target: API_URL,
    changeOrigin: true
}));

// Serve index.html for all other routes
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
    console.log(`Website server running on port ${PORT}`);
    console.log(`Proxying API requests to ${API_URL}`);
});
