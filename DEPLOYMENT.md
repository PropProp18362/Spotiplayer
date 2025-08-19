# SpotiVisualizer Web Deployment Guide

This guide explains how to deploy SpotiVisualizer to Vercel as a web application.

## Prerequisites

1. A [Vercel](https://vercel.com) account
2. [Git](https://git-scm.com/) installed on your machine
3. [Flutter](https://flutter.dev/docs/get-started/install) installed and configured for web development

## Building for Web

1. Make sure Flutter web is enabled:
   ```
   flutter config --enable-web
   ```

2. Build the web version:
   ```
   flutter build web --release
   ```

3. The built files will be in the `build/web` directory

## Deploying to Vercel

### Option 1: Using Vercel CLI

1. Install Vercel CLI:
   ```
   npm install -g vercel
   ```

2. Login to Vercel:
   ```
   vercel login
   ```

3. Deploy from the project root:
   ```
   vercel
   ```

4. Follow the prompts to complete the deployment

### Option 2: Using Vercel Dashboard

1. Push your code to a Git repository (GitHub, GitLab, or Bitbucket)

2. Log in to [Vercel Dashboard](https://vercel.com/dashboard)

3. Click "New Project"

4. Import your Git repository

5. Configure the project:
   - Framework Preset: Other
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: Leave empty

6. Click "Deploy"

## Configuring Spotify Redirect URI

After deployment, you need to update your Spotify Developer Dashboard with the new redirect URI:

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)

2. Select your SpotiVisualizer app

3. Click "Edit Settings"

4. Add the following redirect URI:
   ```
   https://your-vercel-domain.vercel.app/auth/callback
   ```
   Replace `your-vercel-domain` with your actual Vercel domain

5. Save changes

## Updating the App Configuration

Before deploying to production, update the redirect URI in the app:

1. Open `lib/config/app_config.dart`

2. Uncomment and update the production redirect URI:
   ```dart
   // For production
   static const String redirectUri = 'https://your-vercel-domain.vercel.app/auth/callback';
   // Comment out the local development URI
   // static const String redirectUri = 'http://localhost:4200/auth/callback';
   ```

3. Rebuild and deploy

## Troubleshooting

### CORS Issues

If you encounter CORS issues with Spotify API:

1. Add the following to your `vercel.json` file:
   ```json
   "headers": [
     {
       "source": "/api/(.*)",
       "headers": [
         { "key": "Access-Control-Allow-Credentials", "value": "true" },
         { "key": "Access-Control-Allow-Origin", "value": "*" },
         { "key": "Access-Control-Allow-Methods", "value": "GET,OPTIONS,PATCH,DELETE,POST,PUT" },
         { "key": "Access-Control-Allow-Headers", "value": "X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization" }
       ]
     }
   ]
   ```

### Authentication Issues

If authentication fails:

1. Check that the redirect URI in Spotify Developer Dashboard exactly matches your app configuration
2. Ensure your app is properly handling the callback URL
3. Try using incognito/private browsing mode to avoid cookie issues

## Switching to Spotify's Official Website

To change the redirect URI to Spotify's official website:

1. Update the redirect URI in `lib/config/app_config.dart`:
   ```dart
   static const String redirectUri = 'https://open.spotify.com/callback';
   ```

2. Update your Spotify Developer Dashboard with the same URI

3. Implement the necessary changes to handle authentication through Spotify's official website

Note: Using Spotify's official website as a redirect URI requires additional coordination with Spotify. You may need to contact Spotify Developer Support for approval.