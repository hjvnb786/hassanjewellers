# Force Update Feature

## Overview
The Hassan Jewellers app now includes a force update mechanism that ensures users are running the latest version of the app. This feature helps maintain app security, fix critical bugs, and ensure all users have access to the latest features.

## How It Works

### 1. Version Check
- The app checks for updates every time it starts
- It compares the current app version with a required version stored in Firestore
- If the current version is lower than the required version, a force update screen is shown

### 2. Firestore Configuration
The force update version is stored in Firestore at:
```
Collection: info
Document: operations
Field: forceUpdateVersion (String)
```

### 3. Version Comparison
The app uses semantic versioning (e.g., `1.1.0`) and compares versions as follows:
- **Major version**: Breaking changes (e.g., 1.x.x vs 2.x.x)
- **Minor version**: New features (e.g., 1.1.x vs 1.2.x)
- **Patch version**: Bug fixes (e.g., 1.1.0 vs 1.1.1)

## Setup Instructions

### 1. Create Firestore Document
Create a document in your Firestore database:

```javascript
// Collection: info
// Document: operations
{
  "forceUpdateVersion": "1.2.0"  // Set this to the minimum required version
}
```

### 2. Configure Store URLs in Firestore
Add the store URLs to your Firestore document:

```javascript
// Collection: info
// Document: operations
{
  "forceUpdateVersion": "1.2.0",
  "playStoreUrl": "https://play.google.com/store/apps/details?id=com.hassanjewellers.jewelleryapp",
  "appStoreUrl": "https://apps.apple.com/app/your-actual-app-id"
}
```

### 3. Test the Feature
To test the force update feature:

1. **Set a higher version in Firestore**: Set `forceUpdateVersion` to a version higher than your current app version
2. **Use debug method**: Call `ForceUpdateService.isForceUpdateRequiredDebug(testVersion: "1.0.0")` to test with a specific version
3. **Temporarily lower app version**: Change the version in `pubspec.yaml` to test the force update screen

## Usage Examples

### Example 1: Force Update for Critical Bug Fix
```javascript
// In Firestore operations document
{
  "forceUpdateVersion": "1.1.1",  // Force update for patch version
  "playStoreUrl": "https://play.google.com/store/apps/details?id=com.hassanjewellers.jewelleryapp",
  "appStoreUrl": "https://apps.apple.com/app/your-app-id"
}
```

### Example 2: Force Update for Major Feature
```javascript
// In Firestore operations document
{
  "forceUpdateVersion": "1.2.0",  // Force update for minor version
  "playStoreUrl": "https://play.google.com/store/apps/details?id=com.hassanjewellers.jewelleryapp",
  "appStoreUrl": "https://apps.apple.com/app/your-app-id"
}
```

### Example 3: Disable Force Update
```javascript
// In Firestore operations document
{
  "forceUpdateVersion": "",  // Empty string disables force update
  "playStoreUrl": "https://play.google.com/store/apps/details?id=com.hassanjewellers.jewelleryapp",
  "appStoreUrl": "https://apps.apple.com/app/your-app-id"
}
```

## Files Modified

### New Files Created:
1. `lib/Services/firebase_services/check_force_update.dart` - Force update service
2. `lib/Screens/force_update_screen.dart` - Force update UI screen
3. `FORCE_UPDATE_README.md` - This documentation

### Modified Files:
1. `lib/main.dart` - Added force update check on app startup
2. `pubspec.yaml` - Added `package_info_plus` dependency

## User Experience

### Normal Flow:
1. User opens app
2. App checks for updates (shows loading screen briefly)
3. If no update required → Normal app flow
4. If update required → Force update screen

### Force Update Screen Features:
- Modern, branded UI matching app design
- Clear explanation of why update is needed
- Direct link to app store
- No way to bypass the update (force update)
- Loading state while checking for updates

## Error Handling

The force update system includes robust error handling:

- **Network errors**: App continues normally if update check fails
- **Missing Firestore document**: App continues normally
- **Invalid version format**: App continues normally
- **Firebase connection issues**: App continues normally

## Testing

### Manual Testing:
1. Set `forceUpdateVersion` in Firestore to a version higher than current
2. Restart the app
3. Verify force update screen appears
4. Test app store link functionality

### Debug Testing:
```dart
// Test with specific version
bool updateRequired = await ForceUpdateService.isForceUpdateRequiredDebug(
  testVersion: "1.0.0"
);
```

## Security Considerations

- The force update check happens on app startup
- Users cannot bypass the force update screen
- Version comparison is done client-side for performance
- Fallback behavior allows app to continue if update check fails

## Troubleshooting

### Common Issues:

1. **Force update not triggering**:
   - Check Firestore document exists and has correct field name
   - Verify version format (e.g., "1.1.0")
   - Check network connectivity

2. **App store links not working**:
   - Update URLs in `force_update_screen.dart`
   - Test URLs manually in browser
   - Check app store listing is live

3. **Version comparison issues**:
   - Ensure version format is semantic (e.g., "1.1.0")
   - Check for typos in version strings
   - Use debug method to test specific versions

## Future Enhancements

Potential improvements for the force update feature:

1. **Soft updates**: Allow users to skip non-critical updates
2. **Update notifications**: Show update available notification
3. **In-app updates**: Direct download and installation
4. **Update changelog**: Show what's new in the update
5. **Scheduled updates**: Force updates at specific times
