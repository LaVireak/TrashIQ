# TrashIQ Web Deployment

This guide explains how to deploy the TrashIQ Flutter app to Vercel for web testing.

## Quick Deploy to Vercel

### Option 1: Vercel CLI (Recommended)

1. **Install Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel:**
   ```bash
   vercel login
   ```

3. **Deploy from project root:**
   ```bash
   cd "c:\Users\lavir\OneDrive\Desktop\Project 1\TrashIQ"
   vercel
   ```

4. **Follow the prompts:**
   - Set up and deploy? **Y**
   - Which scope? **Your account**
   - Link to existing project? **N**
   - Project name? **trashiq**
   - Directory to deploy? **frontend/build/web**

### Option 2: Drag & Drop (Quick Test)

1. **Build the app:**
   ```bash
   cd frontend
   flutter build web
   ```

2. **Visit [vercel.com](https://vercel.com)**

3. **Drag the `frontend/build/web` folder** to the Vercel dashboard

## What Works on Web

✅ **Available Features:**
- User authentication (Firebase Auth)
- User registration and login
- Profile management
- Navigation and UI
- Points display (simulated for web)
- Leaderboard viewing
- Settings and preferences

⚠️ **Limited Features:**
- Camera functionality (limited browser support)
- File uploads (basic browser support)

❌ **Not Available:**
- AI waste detection (requires backend)
- Real-time image processing
- Push notifications

## Firebase Configuration

Make sure your Firebase project is configured for web:

1. **Add your web app** in Firebase Console
2. **Update `firebase_options.dart`** with web configuration
3. **Enable Authentication** providers you want to use
4. **Set up Firestore** with proper security rules

## Testing the Deployment

Once deployed, you can test:

- Navigate through the app
- Register a new account
- Log in with existing credentials
- View profile and points
- Check responsive design on different devices

## Notes

- The web version runs in "simulation mode" for backend-dependent features
- Points are updated locally only (not synced with Firestore in web mode)
- Camera features may not work on all browsers
- For full functionality, deploy the backend separately

## Environment Variables

If needed, add environment variables in Vercel dashboard:
- `FLUTTER_WEB_USE_SKIA=true`
- `FLUTTER_WEB_AUTO_DETECT=true`

## Build Configuration

The app is configured with:
- **Build Command:** `cd frontend && flutter build web`
- **Output Directory:** `frontend/build/web`
- **Rewrites:** All routes to `/index.html` for SPA routing
