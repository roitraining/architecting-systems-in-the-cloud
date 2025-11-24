# Events App - Kubernetes Demo

Modern full-stack application demonstrating frontend-backend communication in Kubernetes.

## Architecture

```
Frontend (Port 3000)  →  Backend API (Port 3001)
     ↓                         ↓
Static HTML/JS/CSS      Express.js REST API
Bootstrap 5 UI          In-memory data store
```

## Project Structure

```
events-app/
├── frontend/           # Static web frontend
│   ├── index.html     # Main HTML page
│   ├── app.js         # JavaScript frontend logic
│   ├── style.css      # Custom styles
│   ├── package.json   # Frontend dependencies
│   └── Dockerfile     # Frontend container
├── backend/           # Node.js API server
│   ├── server.js      # Express.js API server
│   ├── package.json   # Backend dependencies
│   └── Dockerfile     # Backend container
├── kubernetes/        # Kubernetes deployment files
└── README.md          # This file
```

## Features

### Frontend
- **Modern UI**: Bootstrap 5 with custom styling
- **Responsive Design**: Works on desktop and mobile
- **Real-time Updates**: Automatic refresh of events list
- **Health Monitoring**: Shows backend connection status
- **Form Validation**: Client-side validation for new events

### Backend
- **REST API**: Full CRUD operations for events
- **CORS Enabled**: Allows cross-origin requests
- **Health Endpoint**: `/health` for monitoring
- **Error Handling**: Proper HTTP status codes
- **Input Validation**: Server-side validation

## API Endpoints

- `GET /health` - Health check
- `GET /api/events` - List all events
- `GET /api/events/:id` - Get specific event
- `POST /api/events` - Create new event
- `DELETE /api/events/:id` - Delete event

## Local Development

### Backend
```bash
cd backend
npm install
npm run dev  # Uses nodemon for auto-restart
```

### Frontend
```bash
cd frontend
npm install
npm start    # Serves on http://localhost:3000
```

## Kubernetes Deployment

Deploy both frontend and backend to Kubernetes cluster:

```bash
cd kubernetes
kubectl apply -f .
```

## Modernizations from Original

- **Updated Dependencies**: Latest Node.js 18, Express 4.18, Bootstrap 5
- **Modern JavaScript**: ES6+ features, fetch API, async/await
- **Improved UI**: Better styling, animations, responsive design
- **Health Monitoring**: Backend health status display
- **Error Handling**: Better error messages and user feedback
- **Security**: Input sanitization and validation
- **Container Ready**: Dockerfiles for both services