# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2024-01-15

### Added
- **Migration System**: Complete migration functionality to move `additionalDetails` from inside `personalDetails` to top level
- **Migration UI**: Added "Migrate Data" button in Account screen for easy data migration
- **Improved Data Structure**: Better organization of Firestore documents with `additionalDetails` as a separate top-level object
- **Migration Documentation**: Comprehensive guide in `MIGRATION_README.md` for users and developers

### Changed
- **Document Structure**: Updated Firestore savings collection to have cleaner, more organized structure
- **Scheme Creation**: New schemes now use improved structure with `additionalDetails` at top level
- **Scheme Display**: Updated scheme progress screen to read `additionalDetails` from correct location
- **Data Organization**: Separated personal details from additional details for better maintainability

### Technical Improvements
- **Backward Compatibility**: Existing data preserved during migration
- **Error Handling**: Robust migration system with proper error handling and user feedback
- **Code Quality**: Improved code organization and maintainability
- **Documentation**: Added comprehensive migration documentation

### Migration Features
- **Automatic Migration**: One-tap migration from Account screen
- **Manual Migration**: Developer functions for programmatic migration
- **Migration Status**: Functions to check if documents need migration
- **Single Document Migration**: Ability to migrate individual documents

## [1.0.2] - Previous Release

### Added
- Initial release with basic functionality
- User authentication and registration
- Scheme management and progress tracking
- Payment integration
- Address management

### Changed
- Various bug fixes and improvements

## [1.0.1] - Previous Release

### Added
- Initial app features
- Basic UI and navigation

### Changed
- Performance improvements
- Bug fixes

## [1.0.0] - Initial Release

### Added
- Initial Hassan Jewellers app
- Basic scheme management
- User authentication
- Firestore integration
