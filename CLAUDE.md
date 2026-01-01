# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Friends iOS is a SwiftUI-based iOS application that helps users manage a contact list of friends with photos, phone numbers, and other contact information. The app is a fully-native iOS application using modern Swift frameworks (SwiftUI, SwiftData) with no external dependencies.

## Build & Development Commands

### Building the App

```bash
# Open project in Xcode
open Friends/Friends.xcodeproj

# Build from command line (debug)
xcodebuild -project Friends/Friends.xcodeproj -scheme Friends -configuration Debug

# Build for release
xcodebuild -project Friends/Friends.xcodeproj -scheme Friends -configuration Release
```

### Running in Simulator

```bash
# Build and run in default simulator
xcodebuild -project Friends/Friends.xcodeproj -scheme Friends -configuration Debug -destination 'generic/platform=iOS Simulator' | xcpretty

# Run on specific simulator device
xcodebuild -project Friends/Friends.xcodeproj -scheme Friends -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Quality & Linting

No built-in linting or formatting tools are currently configured. For future development, consider:
- Adding SwiftLint for code style consistency
- Adding SwiftFormat for automatic formatting

### Testing

The project currently does not have an explicit test suite configured. The primary testing approach is:
1. Manual testing via Xcode's preview canvas
2. Preview data in `Pet.swift` can be used for SwiftUI previews
3. Testing the app in the iOS Simulator

## Architecture Overview

### Design Pattern: MVVM (SwiftUI-style)

The app uses a modern MVVM architecture adapted for SwiftUI:

- **Model**: Data layer using `SwiftData` with the `Pet` entity
- **View**: Pure SwiftUI components using reactive property wrappers
- **ViewModel Logic**: Embedded directly in views using `@State`, `@Bindable`, `@Environment`, and `@Query` macros

This approach is the recommended pattern for modern SwiftUI apps and avoids unnecessary abstraction layers.

### Data Persistence

**Technology**: SwiftData (Apple's modern successor to Core Data)

- **Storage**: SQLite database in the app's Application Support directory
- **Default Database**: `default.store`
- **Core Entity**: `Pet` (defined in `Pet.swift`)
  - Properties: name, photo (external storage), sortOrder, dateAdded, notes, isFavorite, phoneNumber, recentMessages array
  - Photo data uses `@Attribute(.externalStorage)` to optimize storage

**Error Recovery**: The app implements database corruption detection with fallback strategies:
- Attempts to recover by deleting corrupted database
- Falls back to in-memory storage if cleanup fails
- Logs debug information at each step

### Key Components

1. **FriendsApp.swift** - Application entry point
   - Initializes SwiftData ModelContainer
   - Handles database migration and error recovery

2. **ContentView.swift** - Main list/grid view
   - Displays friends in adaptive grid layout (2-4 columns based on screen size)
   - Features: search (name/phone), multi-sort options, favorites filtering, drag-and-drop reordering
   - Implements custom `FlowLayout` for dynamic card sizing
   - Provides quick actions: Call, Message, FaceTime

3. **EditPetView.swift** - Friend detail and editing
   - Photo picker integration (PhotosUI framework)
   - Contact importer (Contacts framework)
   - Form-based UI for editing friend information

4. **InitialsProfileView.swift** - Reusable profile component
   - Displays initials on colored circular background
   - Generates consistent gradient colors based on name hash
   - Fallback when photo unavailable

5. **MessageComposerView.swift** - Native messaging integration
   - UIViewControllerRepresentable wrapper for MFMessageComposeViewController
   - Enables native message composition

6. **CustomContentUnavailableView.swift** - Empty state component
   - Reusable empty state UI

### Custom Implementations

- **FlowLayout**: Custom SwiftUI Layout protocol implementation for adaptive grid wrapping
- **PetDropDelegate**: Handles drag-and-drop reordering in the grid with sortOrder persistence
- **ContactPicker**: UIViewControllerRepresentable wrapper for native contact selection
- **State Management**: Uses `@Query` macro for SwiftData integration, `@Bindable` for form binding, and `@Environment` for ModelContext access

### Responsive Design

- Adaptive grid layout that scales from 2-4 columns based on device width
- Semi-transparent `.ultraThinMaterial` cards for modern iOS look
- Haptic feedback integration (light, medium, selection feedback)
- Spring animations for smooth transitions

## Dependencies

**No external third-party dependencies** - the project uses only native iOS frameworks:

- SwiftUI
- SwiftData
- PhotosUI
- Contacts / ContactsUI
- MessageUI
- UIKit (for haptic feedback)
- UniformTypeIdentifiers

## File Structure

```
Friends/
├── Friends.xcodeproj/        # Xcode project file
└── Friends/                   # Main app source
    ├── FriendsApp.swift       # Entry point & database setup
    ├── ContentView.swift      # Main grid view
    ├── EditPetView.swift      # Edit/detail view
    ├── Pet.swift              # Data model
    ├── InitialsProfileView.swift
    ├── MessageComposerView.swift
    ├── CustomContentUnavailableView.swift
    └── Assets.xcassets/       # Images and app icons
```

## Important Implementation Details

### Database Initialization

The app initializes SwiftData with a custom ModelContainer that:
- Creates the Pet schema
- Attempts recovery if database is corrupted
- Provides detailed debug logging with emoji markers for easy scanning

See `FriendsApp.swift` for the implementation.

### View State Management

Views use `@Query` macro to automatically fetch and observe Pet data:
```swift
@Query var pets: [Pet]
@Query(sort: \.name) var sortedByName: [Pet]
```

Forms use `@Bindable` for direct model binding:
```swift
@Bindable var pet: Pet
```

The ModelContext is accessed via environment:
```swift
@Environment(\.modelContext) var modelContext
```

### Photo Storage

Photos are stored externally via SwiftData's `@Attribute(.externalStorage)`, which:
- Stores large binary data separately from the main database
- Improves database performance
- Keeps SQLite lean

### Haptic Feedback

The app uses three UIKit haptic feedback generators for tactile user feedback on interactions. These are initialized once and reused throughout the views.

## Git Workflow

The main branch is `main`. Feature branches are created for development work. Recent commits indicate focus areas:
- UIEnhancements (current branch: `several_cool_UI_enhancements`)
- FaceTime feature integration
- Layout bug fixes
- Texting feature

## Notes for Future Development

1. **Testing**: Consider adding unit tests and UI tests with XCTest
2. **Code Formatting**: Consider adding SwiftLint and SwiftFormat configuration
3. **Localization**: Currently no multi-language support; could be added with Localizable.strings
4. **Analytics**: No analytics integration; can be added if needed
5. **Performance**: The custom FlowLayout is performant; monitor if adding many thousands of friends
