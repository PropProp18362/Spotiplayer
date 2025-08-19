const fs = require('fs');
const path = require('path');

// Main build function
async function build() {
  console.log('Starting Vercel build process for static web app...');
  
  // Create build directories
  console.log('Creating web directory structure...');
  if (!fs.existsSync('build')) {
    fs.mkdirSync('build');
  }
  if (!fs.existsSync('build/web')) {
    fs.mkdirSync('build/web');
  }
  if (!fs.existsSync('build/web/auth')) {
    fs.mkdirSync('build/web/auth');
  }
  
  // Copy static HTML file to build directory
  console.log('Copying static files...');
  try {
    const staticHtml = fs.readFileSync('static-index.html', 'utf8');
    fs.writeFileSync('build/web/index.html', staticHtml);
    // Also create a callback page
    fs.writeFileSync('build/web/auth/callback', staticHtml);
    fs.writeFileSync('build/web/auth/callback/index.html', staticHtml);
  } catch (error) {
    console.error('Error copying static files:', error);
    process.exit(1);
  }
  
  // Create a simple manifest.json file
  const manifestJson = `{
  "name": "SpotiPlayer",
  "short_name": "SpotiPlayer",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#121212",
  "theme_color": "#1DB954",
  "description": "A beautiful Spotify music visualizer",
  "orientation": "portrait-primary"
}`;
  
  fs.writeFileSync('build/web/manifest.json', manifestJson);
  
  console.log('Static web files created successfully.');
  console.log('Build process completed successfully!');
}

// Run the build process
build().catch(error => {
  console.error('Build failed:', error);
  process.exit(1);
});