// Simple Express server for handling Spotify authentication
const express = require('express');
const path = require('path');
const axios = require('axios');
const cors = require('cors');
const querystring = require('querystring');

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Spotify credentials
const CLIENT_ID = 'd37b7146ee274b33bf6539611a0c307e';
const CLIENT_SECRET = 'e63d3d9982c84339bbe9c0c0fe012f50';
const REDIRECT_URI = process.env.REDIRECT_URI || 'http://localhost:3000/auth/callback';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'build/web')));

// Routes
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

// Spotify login route
app.get('/login', (req, res) => {
  const scopes = [
    'user-read-currently-playing',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-private',
    'user-read-email',
    'streaming'
  ];

  res.redirect('https://accounts.spotify.com/authorize?' +
    querystring.stringify({
      response_type: 'code',
      client_id: CLIENT_ID,
      scope: scopes.join(' '),
      redirect_uri: REDIRECT_URI,
      show_dialog: true
    }));
});

// Spotify callback route
app.get('/auth/callback', async (req, res) => {
  const code = req.query.code || null;
  const error = req.query.error || null;

  if (error) {
    return res.redirect('/#' + querystring.stringify({ error }));
  }

  try {
    // Exchange code for access token
    const response = await axios({
      method: 'post',
      url: 'https://accounts.spotify.com/api/token',
      params: {
        code: code,
        redirect_uri: REDIRECT_URI,
        grant_type: 'authorization_code'
      },
      headers: {
        'Authorization': 'Basic ' + Buffer.from(CLIENT_ID + ':' + CLIENT_SECRET).toString('base64'),
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    const { access_token, refresh_token, expires_in } = response.data;

    // Redirect to the frontend with tokens
    res.redirect('/#' + querystring.stringify({
      access_token,
      refresh_token,
      expires_in
    }));
  } catch (error) {
    console.error('Error exchanging code for token:', error.response?.data || error.message);
    res.redirect('/#' + querystring.stringify({ error: 'invalid_token' }));
  }
});

// Refresh token route
app.post('/refresh_token', async (req, res) => {
  const { refresh_token } = req.body;

  if (!refresh_token) {
    return res.status(400).json({ error: 'Refresh token is required' });
  }

  try {
    const response = await axios({
      method: 'post',
      url: 'https://accounts.spotify.com/api/token',
      params: {
        grant_type: 'refresh_token',
        refresh_token: refresh_token
      },
      headers: {
        'Authorization': 'Basic ' + Buffer.from(CLIENT_ID + ':' + CLIENT_SECRET).toString('base64'),
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error refreshing token:', error.response?.data || error.message);
    res.status(400).json({ error: 'invalid_token' });
  }
});

// Catch-all route to handle client-side routing
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Visit http://localhost:${PORT} to view the app`);
});