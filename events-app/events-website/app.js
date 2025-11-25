// Configuration
const API_BASE_URL = window.location.hostname === 'localhost' 
    ? 'http://localhost:3001' 
    : 'http://events-backend-service:3001';

// DOM Elements
const eventsList = document.getElementById('events-list');
const eventForm = document.getElementById('event-form');
const backendStatus = document.getElementById('backend-status');

// Load events on page load
document.addEventListener('DOMContentLoaded', () => {
    loadEvents();
    checkBackendHealth();
    
    // Check backend health every 30 seconds
    setInterval(checkBackendHealth, 30000);
});

// Event form submission
eventForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const formData = {
        title: document.getElementById('title').value,
        date: document.getElementById('date').value,
        location: document.getElementById('location').value,
        description: document.getElementById('description').value
    };

    try {
        const response = await fetch(`${API_BASE_URL}/api/events`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });

        if (response.ok) {
            eventForm.reset();
            loadEvents();
            showAlert('Event added successfully!', 'success');
        } else {
            throw new Error('Failed to add event');
        }
    } catch (error) {
        console.error('Error adding event:', error);
        showAlert('Failed to add event. Please try again.', 'danger');
    }
});

// Load and display events
async function loadEvents() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/events`);
        const events = await response.json();
        
        displayEvents(events);
    } catch (error) {
        console.error('Error loading events:', error);
        eventsList.innerHTML = `
            <div class="col-12">
                <div class="alert alert-danger" role="alert">
                    Failed to load events. Please check if the backend service is running.
                </div>
            </div>
        `;
    }
}

// Display events in the UI
function displayEvents(events) {
    if (events.length === 0) {
        eventsList.innerHTML = `
            <div class="col-12">
                <div class="alert alert-info" role="alert">
                    No events found. Add your first event!
                </div>
            </div>
        `;
        return;
    }

    eventsList.innerHTML = events.map(event => `
        <div class="col-md-6 mb-3">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">${escapeHtml(event.title)}</h5>
                    <p class="card-text">
                        <strong>📅 Date:</strong> ${formatDate(event.date)}<br>
                        <strong>📍 Location:</strong> ${escapeHtml(event.location)}<br>
                        ${event.description ? `<strong>📝 Description:</strong> ${escapeHtml(event.description)}` : ''}
                    </p>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteEvent(${event.id})">
                        Delete
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

// Delete event
async function deleteEvent(eventId) {
    if (!confirm('Are you sure you want to delete this event?')) {
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/api/events/${eventId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            loadEvents();
            showAlert('Event deleted successfully!', 'success');
        } else {
            throw new Error('Failed to delete event');
        }
    } catch (error) {
        console.error('Error deleting event:', error);
        showAlert('Failed to delete event. Please try again.', 'danger');
    }
}

// Check backend health
async function checkBackendHealth() {
    try {
        const response = await fetch(`${API_BASE_URL}/health`);
        const health = await response.json();
        
        backendStatus.textContent = '✅ Connected';
        backendStatus.className = 'text-success';
    } catch (error) {
        backendStatus.textContent = '❌ Disconnected';
        backendStatus.className = 'text-danger';
    }
}

// Utility functions
function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function showAlert(message, type) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.querySelector('.container').insertBefore(alertDiv, document.querySelector('.row'));
    
    setTimeout(() => {
        alertDiv.remove();
    }, 5000);
}