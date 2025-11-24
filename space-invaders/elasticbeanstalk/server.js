const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 8080;

// Serve static files from src directory
app.use(express.static(path.join(__dirname, '../src')));

// Route for root
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../src/index.html'));
});

app.listen(port, () => {
  console.log(`Space Invaders app listening on port ${port}`);
});