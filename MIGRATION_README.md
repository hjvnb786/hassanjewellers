# AdditionalDetails Migration

## Overview
This migration moves the `additionalDetails` object from inside `personalDetails` to the top level of the Firestore savings collection documents.

## Changes Made

### 1. Document Structure Changes

**Before:**
```json
{
  "userId": "...",
  "status": true,
  "createdAt": "...",
  "installmentCount": 1,
  "personalDetails": {
    "firstName": "...",
    "lastName": "...",
    "mobile": "...",
    "email": "...",
    "deliveryAddress": "...",
    "additionalDetails": {
      // Additional fields here
    }
  },
  "schemeDetails": { ... },
  "schemeProgress": { ... }
}
```

**After:**
```json
{
  "userId": "...",
  "status": true,
  "createdAt": "...",
  "installmentCount": 1,
  "personalDetails": {
    "firstName": "...",
    "lastName": "...",
    "mobile": "...",
    "email": "...",
    "deliveryAddress": "..."
  },
  "additionalDetails": {
    // Additional fields here
  },
  "schemeDetails": { ... },
  "schemeProgress": { ... }
}
```

### 2. Code Changes

#### Files Modified:

1. **`lib/Services/firebase_services/addNewScheme.dart`**
   - Moved `additionalDetails` from inside `personalDetails` to top level
   - New documents will use the updated structure

2. **`lib/Screens/scheme_progress_screen.dart`**
   - Updated `_buildAdditionalDetails()` to read from top level
   - Removed logic that skipped `additionalDetails` when displaying `personalDetails`

3. **`lib/Services/firebase_services/migrateAdditionalDetails.dart`** (New)
   - Created migration functions to update existing documents
   - Includes functions to migrate all documents or single documents

4. **`lib/Screens/account_screen.dart`**
   - Added migration UI button in "More Options" section
   - Users can run migration from the app

## Migration Process

### Automatic Migration (Recommended)
1. Open the app and go to Account screen
2. Tap "More Options" → "Migrate Data"
3. Confirm the migration
4. Wait for completion

### Manual Migration (For Developers)
```dart
// Migrate all documents for current user
await migrateAdditionalDetails();

// Check if specific document needs migration
bool needsMigration = await needsMigration(documentId);

// Migrate single document
bool success = await migrateSingleDocument(documentId);
```

## Benefits

1. **Better Data Organization**: Additional details are now separate from personal details
2. **Cleaner Structure**: Each section has a clear purpose
3. **Easier Maintenance**: Simpler to add new additional fields
4. **Consistent with schemeDetails**: All major sections are at the top level

## Backward Compatibility

- The migration preserves all existing data
- No data loss during migration
- Existing functionality continues to work
- New documents use the updated structure

## Testing

After migration, verify:
1. All existing schemes display correctly
2. Additional details are shown in the correct section
3. New schemes are created with the correct structure
4. No data is lost or corrupted

## Rollback (If Needed)

If issues occur, you can rollback by:
1. Reverting the code changes
2. Running a reverse migration to move `additionalDetails` back inside `personalDetails`

## Notes

- This is a one-time migration
- Run migration before deploying to production
- Test thoroughly in development environment first
- Monitor logs during migration for any errors
