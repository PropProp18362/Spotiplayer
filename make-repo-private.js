const https = require('https');

// GitHub repository details
const owner = 'PropProp18362';
const repo = 'Spotiplayer';

// You'll need to create a personal access token with 'repo' scope
// and replace 'YOUR_PERSONAL_ACCESS_TOKEN' with it
// Visit https://github.com/settings/tokens to create one
console.log('To make your repository private, you need to:');
console.log('1. Go to https://github.com/settings/tokens');
console.log('2. Generate a new token with "repo" scope');
console.log('3. Use that token in this script');
console.log('4. Or simply go to https://github.com/PropProp18362/Spotiplayer/settings and change visibility there');

// This is a placeholder - you should replace it with your actual token
// and run the script locally, not commit the token to the repository
const personalAccessToken = 'YOUR_PERSONAL_ACCESS_TOKEN';

// Only proceed if a real token is provided
if (personalAccessToken === 'YOUR_PERSONAL_ACCESS_TOKEN') {
  console.log('\nThis script contains a placeholder token.');
  console.log('Please edit the script and replace YOUR_PERSONAL_ACCESS_TOKEN with your actual token.');
  console.log('\nAlternatively, you can make the repository private directly on GitHub:');
  console.log('1. Go to https://github.com/PropProp18362/Spotiplayer/settings');
  console.log('2. Scroll down to the "Danger Zone"');
  console.log('3. Click "Change repository visibility"');
  console.log('4. Select "Make private" and follow the prompts');
  process.exit(1);
}

const options = {
  hostname: 'api.github.com',
  path: `/repos/${owner}/${repo}`,
  method: 'PATCH',
  headers: {
    'User-Agent': 'Node.js',
    'Content-Type': 'application/json',
    'Authorization': `token ${personalAccessToken}`,
    'Accept': 'application/vnd.github.v3+json'
  }
};

const req = https.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    if (res.statusCode === 200) {
      console.log('Repository visibility changed successfully!');
      console.log('Your repository is now private.');
    } else {
      console.error(`Error: ${res.statusCode}`);
      console.error(data);
    }
  });
});

req.on('error', (error) => {
  console.error('Error making request:', error);
});

// Send the request with the data
req.write(JSON.stringify({ private: true }));
req.end();