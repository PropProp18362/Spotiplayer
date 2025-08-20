const fs = require('fs');
const path = require('path');

// Helper function to copy directory recursively
function copyDir(src, dest) {
  // Create destination directory if it doesn't exist
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  
  // Read all files in source directory
  const entries = fs.readdirSync(src, { withFileTypes: true });
  
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    
    if (entry.isDirectory()) {
      // Recursively copy subdirectories
      copyDir(srcPath, destPath);
    } else {
      // Copy files
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

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
    
    // Read new HTML content
    console.log('Reading HTML file...');
    const newHtml = fs.existsSync('new-index.html') 
      ? fs.readFileSync('new-index.html', 'utf8')
      : fs.readFileSync('static-index.html', 'utf8');
    
    // Write files
    console.log('Writing files to build directory...');
    fs.writeFileSync('build/web/index.html', newHtml);
    
    // Copy Flutter web app files if they exist
    if (fs.existsSync('web')) {
      console.log('Copying Flutter web app files...');
      copyDir('web', 'build/web/web');
    }
    
    // Create the visualizer directory if it doesn't exist
    if (!fs.existsSync('build/web/visualizer')) {
      fs.mkdirSync('build/web/visualizer', { recursive: true });
    }
    
    // Copy visualizer HTML file if it exists
    if (fs.existsSync('visualizer.html')) {
      console.log('Copying visualizer HTML file...');
      fs.copyFileSync('visualizer.html', 'build/web/visualizer/index.html');
    } else {
      // Create the visualizer directory if it doesn't exist
      if (!fs.existsSync('build/web/visualizer')) {
        fs.mkdirSync('build/web/visualizer', { recursive: true });
      }
      
      // Create a simple redirect HTML file
      const redirectHtml = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>SpotiPlayer Visualizer</title>
  <script>
    window.location.href = '/web/index.html';
  </script>
</head>
<body>
  <p>Redirecting to visualizer...</p>
</body>
</html>`;
      
      fs.writeFileSync('build/web/visualizer/index.html', redirectHtml);
    }
    
    // Create a simple manifest.json file
    const manifestJson = `{
  "name": "SpotiPlayer",
  "short_name": "SpotiPlayer",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#050505",
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