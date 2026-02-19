# iOS Safari Troubleshooting Guide

## Common Issues and Solutions

### 1. Google Sign-In Not Working

**Problem:** Google Sign-In button doesn't work or shows errors on iOS Safari.

**Solutions:**

#### A. Check OAuth Redirect URIs in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Credentials**
3. Click on your **Web OAuth 2.0 Client ID**
4. Under **Authorized JavaScript origins**, add:
   - `https://yourdomain.com` (your actual hosting URL)
   - `https://localhost` (for local testing)
5. Under **Authorized redirect URIs**, add:
   - `https://yourdomain.com` (your actual hosting URL)
   - `https://localhost` (for local testing)

#### B. Ensure HTTPS is Enabled

iOS Safari **requires HTTPS** for OAuth flows. Make sure:
- Your hosting uses HTTPS (not HTTP)
- SSL certificate is valid
- No mixed content warnings

#### C. Check Browser Console

On iOS Safari:
1. Connect your iPhone/iPad to Mac
2. Open Safari on Mac → **Develop** → **[Your Device]** → **[Your Site]**
3. Check the console for errors
4. Look for CORS, OAuth, or network errors

### 2. App Not Loading

**Problem:** The Flutter web app doesn't load or shows a blank screen.

**Solutions:**

- **Check HTTPS:** iOS Safari requires HTTPS for service workers and modern web features
- **Check Console:** Use Safari Web Inspector (see above) to check for JavaScript errors
- **Clear Cache:** Clear Safari cache and reload
- **Check Network:** Ensure all assets are loading (check Network tab in Safari Web Inspector)

### 3. CORS Issues

**Problem:** API calls fail with CORS errors.

**Solutions:**

- Ensure your backend allows requests from your domain
- Check backend CORS configuration includes your domain
- Verify `Access-Control-Allow-Origin` headers are set correctly

### 4. Service Worker Issues

**Problem:** App doesn't work offline or has caching issues.

**Solutions:**

- Clear Safari cache: Settings → Safari → Clear History and Website Data
- Disable service worker in Safari Developer menu (if testing)
- Rebuild and redeploy the web app

### 5. Viewport/Scaling Issues

**Problem:** App doesn't scale properly on iOS devices.

**Solutions:**

- The viewport meta tag is now configured in `index.html`
- Ensure `maximum-scale=1.0` is set to prevent zooming issues
- Test on actual iOS device, not just simulator

## Testing on iOS Safari

### Method 1: Safari Web Inspector (Recommended)

1. Connect iPhone/iPad to Mac via USB
2. On iPhone: Settings → Safari → Advanced → Web Inspector (enable)
3. On Mac: Safari → Develop → [Your Device] → [Your Site]
4. Check Console, Network, and Storage tabs

### Method 2: Remote Debugging

1. Use Safari on Mac to test iOS Safari compatibility
2. Enable "Develop" menu: Safari → Preferences → Advanced → Show Develop menu
3. User Agent: Develop → User Agent → Safari — iOS [version]

## Quick Checklist

- [ ] HTTPS is enabled and working
- [ ] OAuth redirect URIs are configured in Google Cloud Console
- [ ] Authorized JavaScript origins include your domain
- [ ] No CORS errors in console
- [ ] Service worker is working (if using PWA features)
- [ ] Tested on actual iOS device, not just simulator
- [ ] Checked Safari Web Inspector for errors
- [ ] Cleared Safari cache if needed

## Additional Resources

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Google Sign-In for Web](https://developers.google.com/identity/sign-in/web)
- [Safari Web Inspector Guide](https://developer.apple.com/library/archive/documentation/AppleApplications/Conceptual/Safari_Developer_Guide/Introduction/Introduction.html)
