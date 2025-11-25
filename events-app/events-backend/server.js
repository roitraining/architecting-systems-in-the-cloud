const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory events storage (replace with database in production)
let events = [
  {
    id: 1,
    title: "AWS re:Invent 2024",
    date: "2024-12-02",
    location: "Las Vegas, NV",
    description: "AWS's premier cloud computing conference"
  },
  {
    id: 2,
    title: "KubeCon + CloudNativeCon",
    date: "2024-11-12",
    location: "Salt Lake City, UT", 
    description: "The flagship conference of the cloud native community"
  },
  {
    id: 3,
    title: "DockerCon 2024",
    date: "2024-10-15",
    location: "Los Angeles, CA",
    description: "The premier event for container developers and IT professionals"
  }
];

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/events', (req, res) => {
  res.json(events);
});

app.get('/api/events/:id', (req, res) => {
  const event = events.find(e => e.id === parseInt(req.params.id));
  if (!event) {
    return res.status(404).json({ error: 'Event not found' });
  }
  res.json(event);
});

app.post('/api/events', (req, res) => {
  const { title, date, location, description } = req.body;
  
  if (!title || !date || !location) {
    return res.status(400).json({ error: 'Title, date, and location are required' });
  }

  const newEvent = {
    id: Math.max(...events.map(e => e.id)) + 1,
    title,
    date,
    location,
    description: description || ''
  };

  events.push(newEvent);
  res.status(201).json(newEvent);
});

app.delete('/api/events/:id', (req, res) => {
  const eventIndex = events.findIndex(e => e.id === parseInt(req.params.id));
  if (eventIndex === -1) {
    return res.status(404).json({ error: 'Event not found' });
  }

  events.splice(eventIndex, 1);
  res.status(204).send();
});

app.listen(PORT, () => {
  console.log(`Events API server running on port ${PORT}`);
});