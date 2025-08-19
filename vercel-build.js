const fs = require('fs');
const path = require('path');

// Main build function
function build() {
  console.log('Starting Vercel build process for static web app...');
  
  try {
    // Create build directories
    console.log('Creating web directory structure...');
    if (!fs.existsSync('build')) {
      fs.mkdirSync('build');
    }
    
    if (!fs.existsSync('build/web')) {
      fs.mkdirSync('build/web');
    }
    
    // Create auth directory
    if (!fs.existsSync('build/web/auth')) {
      fs.mkdirSync('build/web/auth');
    }
    
    // Create callback directory
    if (!fs.existsSync('build/web/auth/callback')) {
      fs.mkdirSync('build/web/auth/callback');
    }
    
    // Read static HTML content
    console.log('Reading static HTML file...');
    const staticHtml = fs.readFileSync('static-index.html', 'utf8');
    
    // Write files
    console.log('Writing files to build directory...');
    fs.writeFileSync('build/web/index.html', staticHtml);
    fs.writeFileSync('build/web/auth/callback/index.html', staticHtml);
    
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
  } catch (error) {
    console.error('Error during build process:', error);
    process.exit(1);
  }
}

// Run the build process
build();