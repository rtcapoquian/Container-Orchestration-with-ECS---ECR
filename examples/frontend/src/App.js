import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './index.css';

function App() {
  const [backendStatus, setBackendStatus] = useState('checking');
  const [healthStatus, setHealthStatus] = useState('checking');

  const checkBackend = async () => {
    try {
      setBackendStatus('loading');
      const response = await axios.get('/api/health');
      setBackendStatus('success');
      return response.data;
    } catch (error) {
      setBackendStatus('error');
      throw error;
    }
  };

  const checkHealth = async () => {
    try {
      setHealthStatus('loading');
      const response = await axios.get('/health');
      setHealthStatus('success');
      return response.data;
    } catch (error) {
      setHealthStatus('error');
      throw error;
    }
  };

  useEffect(() => {
    // Check health endpoints on component mount
    checkHealth();
    checkBackend();
  }, []);

  const getStatusClass = (status) => {
    switch (status) {
      case 'loading': return 'status loading';
      case 'success': return 'status success';
      case 'error': return 'status error';
      default: return 'status';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'loading': return 'Checking...';
      case 'success': return 'Connected ✓';
      case 'error': return 'Error ✗';
      default: return 'Unknown';
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1 className="App-title">🚀 ECS Microservices Frontend</h1>
        <p className="App-subtitle">
          React frontend with nginx reverse proxy for microservices architecture
        </p>
        
        <div className="features">
          <div className="feature-card">
            <h3>🔧 Nginx Reverse Proxy</h3>
            <p>Routes /api requests to backend services</p>
          </div>
          <div className="feature-card">
            <h3>🐳 Docker Ready</h3>
            <p>Multi-stage build with production nginx</p>
          </div>
          <div className="feature-card">
            <h3>☁️ ECS Compatible</h3>
            <p>Health checks and service discovery</p>
          </div>
        </div>

        <div className="status-section">
          <h2>Service Status</h2>
          
          <div className={getStatusClass(healthStatus)}>
            <h4>Frontend Health: {getStatusText(healthStatus)}</h4>
            <button onClick={checkHealth} disabled={healthStatus === 'loading'}>
              Check Frontend Health
            </button>
          </div>

          <div className={getStatusClass(backendStatus)}>
            <h4>Backend API: {getStatusText(backendStatus)}</h4>
            <button onClick={checkBackend} disabled={backendStatus === 'loading'}>
              Check Backend API
            </button>
          </div>
        </div>

        <div className="info">
          <p>
            <strong>Development:</strong> npm start (port 3000)<br/>
            <strong>Production:</strong> docker build -t ecs-frontend . && docker run -p 3000:3000 ecs-frontend
          </p>
        </div>
      </header>
    </div>
  );
}

export default App;
