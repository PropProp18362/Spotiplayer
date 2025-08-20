// Script to clean up documentation files
const fs = require('fs');
const path = require('path');

// Files to keep
const filesToKeep = [
  'README.md',
  'LICENSE',
  '.gitignore'
];

// Files to delete
const filesToDelete = [
  'TROUBLESHOOTING.md',
  'README_WEB.md',
  'PROJECT_STATUS.md',
  'SPOTIFY_SETUP_INSTRUCTIONS.md',
  'COMPLETE_REBUILD_SUMMARY.md',
  'COMPLETE_FIXES_FINAL.md',
  'BUILD_SUCCESS.md',
  'AUTHENTICATION_FIX.md',
  'AUTHENTICATION_FINAL_FIX.md',
  'FINAL_SUMMARY.md',
  'FINAL_FIXES_SUMMARY.md',
  'FINAL_FIXES_COMPLETE.md',
  'DEPLOYMENT.md',
  'HTTPS_IMPLEMENTATION.md',
  'GITHUB_PUSH_INSTRUCTIONS.md',
  'WEB_CONVERSION_SUMMARY.md',
  'UI_FIXES_SUMMARY.md'
];

// Replace README.md with the new consolidated version
console.log('Updating README.md...');
try {
  fs.copyFileSync('NEW_README.md', 'README.md');
  console.log('README.md updated successfully.');
} catch (err) {
  console.error('Error updating README.md:', err);
}

// Delete unnecessary documentation files
console.log('Deleting unnecessary documentation files...');
filesToDelete.forEach(file => {
  try {
    if (fs.existsSync(file)) {
      fs.unlinkSync(file);
      console.log(`Deleted: ${file}`);
    } else {
      console.log(`File not found: ${file}`);
    }
  } catch (err) {
    console.error(`Error deleting ${file}:`, err);
  }
});

// Delete the NEW_README.md file after copying
try {
  fs.unlinkSync('NEW_README.md');
  console.log('Deleted: NEW_README.md');
} catch (err) {
  console.error('Error deleting NEW_README.md:', err);
}

console.log('Documentation cleanup complete!');