# Setup Guide 🛠️

Complete setup instructions for Smart Study Companion.

## Prerequisites

- Xcode 17.0 or later
- iOS 26.2 or later deployment target
- Swift 5.9+
- macOS Ventura or later

## Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/SmartStudyCompanion.git
cd SmartStudyCompanion
```

## Step 2: Open in Xcode

```bash
open SmartStudyCompanion.xcodeproj
```

## Step 3: Create CoreData Model File (IMPORTANT!)

The CoreData model file must be created manually in Xcode:

### Instructions:

1. **In Xcode**, right-click on the `SmartStudyCompanion` folder in Project Navigator
2. Select **"New File..."**
3. Choose **"Data Model"** from the iOS templates
4. Name it: **`SmartStudyCompanion`**
5. Click **Create**

### Add Entities:

You should now have a visual editor. Add these 4 entities:

#### Entity 1: CDSummary
- **Module**: SmartStudyCompanion
- **Codegen**: Manual/None

**Attributes:**
| Attribute | Type | Optional |
|-----------|------|----------|
| id | String | No |
| userId | String | No |
| pdfFileId | String | No |
| title | String | No |
| content | String | No |
| keyPoints | Transformable | No |
| generatedAt | Date | No |
| wordCount | Integer 32 | No |
| readingTime | Integer 32 | No |

#### Entity 2: CDFlashcard
- **Module**: SmartStudyCompanion
- **Codegen**: Manual/None

**Attributes:**
| Attribute | Type | Optional |
|-----------|------|----------|
| id | String | No |
| userId | String | No |
| pdfFileId | String | No |
| setId | String | Yes |
| front | String | No |
| back | String | No |
| difficulty | String | No |
| createdAt | Date | No |
| lastReviewedAt | Date | Yes |
| reviewCount | Integer 32 | No |
| correctCount | Integer 32 | No |

#### Entity 3: CDQuiz
- **Module**: SmartStudyCompanion
- **Codegen**: Manual/None

**Attributes:**
| Attribute | Type | Optional |
|-----------|------|----------|
| id | String | No |
| userId | String | No |
| pdfFileId | String | No |
| title | String | No |
| createdAt | Date | No |
| timeLimit | Integer 32 | Yes |
| passingScore | Integer 32 | No |

#### Entity 4: CDProgress
- **Module**: SmartStudyCompanion
- **Codegen**: Manual/None

**Attributes:**
| Attribute | Type | Optional |
|-----------|------|----------|
| id | String | No |
| userId | String | No |
| pdfFileId | String | No |
| totalTimeSpent | Integer 32 | No |
| cardsStudied | Integer 32 | No |
| cardsRemaining | Integer 32 | No |
| quizzesCompleted | Integer 32 | No |
| averageScore | Double | No |
| lastStudyDate | Date | Yes |
| studyStreak | Integer 32 | No |
| totalCards | Integer 32 | No |
| masteredCards | Integer 32 | No |

## Step 4: Build the Project

```bash
# Build for iPhone Simulator
xcodebuild -scheme SmartStudyCompanion -destination 'platform=iOS Simulator,name=iPhone 17' build

# Or in Xcode: Cmd + B
```

## Step 5: Run the App

```bash
# Run in Xcode
# 1. Select iPhone 17 simulator
# 2. Press Cmd + R

# Or from command line
xcodebuild -scheme SmartStudyCompanion -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug
```

## Step 6: Configure Backend (Optional)

To connect to a FastAPI backend, edit `Services/APIService.swift`:

```swift
init(
    baseURL: URL = URL(string: "http://your-backend-url/api")!,  // Change this
    session: URLSession = .shared
) {
    self.baseURL = baseURL
    self.session = session
    loadStoredTokens()
}
```

## Troubleshooting 🔧

### Build Issues

#### "Cannot find type 'CDSummary' in scope"
**Solution**: Create the CoreData model file (Step 3)

#### "Failed to load Core Data Stack"
**Solution**: Make sure CoreDataManager is initialized in SmartStudyCompanionApp.swift

#### "Module named 'SmartStudyCompanion' not found"
**Solution**: 
1. Clean build folder (Cmd + Shift + K)
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
3. Rebuild (Cmd + B)

### Runtime Issues

#### App crashes on startup
**Check:**
1. All imports are correct
2. CoreData model file exists
3. No circular dependencies in imports

#### API calls failing with 401
**Solution**: Backend is not running or token is invalid
1. Start your FastAPI backend
2. Check API base URL in APIService.swift

#### Simulator not launching
**Solution**:
```bash
# Boot simulator manually
xcrun simctl boot "iPhone 17"

# Or in Xcode:
# Window > Devices and Simulators > Select iPhone 17 > Boot
```

## Development Setup ⚙️

### Environment Variables

Create `.env` file (not tracked in git):

```
API_BASE_URL=http://localhost:8000/api
LOG_LEVEL=debug
CACHE_SIZE=100MB
```

### Useful Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build | Cmd + B |
| Run | Cmd + R |
| Clean Build | Cmd + Shift + K |
| Show Console | Cmd + Shift + C |
| Search | Cmd + F |
| Open Quickly | Cmd + Shift + O |

### Testing

```bash
# Run all tests
xcodebuild -scheme SmartStudyCompanion test

# Run specific test
xcodebuild -scheme SmartStudyCompanion test -only SmartStudyCompanionTests

# Run UI tests
xcodebuild -scheme SmartStudyCompanionUITests test
```

## Code Style Guide 📝

### Naming Conventions

**Files**
- Views: `LoginView.swift`, `UploadView.swift`
- ViewModels: `AuthViewModel.swift`, `UploadViewModel.swift`
- Models: `User.swift`, `Progress.swift`
- Services: `APIService.swift`

**Classes/Structs**
- Use PascalCase: `class AuthViewModel`, `struct User`

**Properties**
- Use camelCase: `isLoading`, `userData`
- Private: `private let apiService`

**Functions**
- Use camelCase: `func login()`, `func fetchUserPDFs()`
- Async functions: `async func fetchData()`

### Import Organization

```swift
import SwiftUI      // Framework imports
import Combine      // (alphabetical order)
import Foundation   // (alphabetical order)

// Then custom imports
// (none for most files)
```

### Comments

```swift
// MARK: - Main Sections
// Use for separating major sections

/// Documentation comment for public APIs
/// - Parameter name: Description
/// - Returns: Description

// Inline comments for complex logic
let value = expensive() // Cache result for reuse
```

## Git Workflow 🔄

### Create Feature Branch

```bash
git checkout -b feature/add-offline-sync
```

### Commit Changes

```bash
git add .
git commit -m "feat: add offline sync functionality"
```

### Push to GitHub

```bash
git push origin feature/add-offline-sync
```

### Create Pull Request

1. Go to GitHub repository
2. Click "New Pull Request"
3. Select your branch
4. Add description
5. Request review

## Deployment Checklist ✅

Before releasing to App Store:

- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Code reviewed
- [ ] CoreData model finalized
- [ ] API endpoints verified
- [ ] Error messages user-friendly
- [ ] Privacy policy added
- [ ] Icons and images in Assets
- [ ] Build configuration for production
- [ ] TestFlight build created

## Security Checklist 🔒

- [ ] No hardcoded credentials
- [ ] API keys in environment variables
- [ ] Tokens stored in Keychain (not UserDefaults)
- [ ] HTTPS only for API calls
- [ ] Input validation on all fields
- [ ] Error messages don't expose internals
- [ ] Logs don't contain sensitive data

## Performance Checklist ⚡

- [ ] Images optimized and cached
- [ ] No unnecessary API calls
- [ ] CoreData queries optimized
- [ ] Main thread not blocked
- [ ] Memory leaks checked
- [ ] App launches in < 2 seconds

## Support 💬

For setup issues:
1. Check this guide thoroughly
2. Review error messages
3. Check Xcode logs (Cmd + Shift + C)
4. Create GitHub issue with:
   - Xcode version
   - iOS version
   - Exact error message
   - Steps to reproduce

---

**Last Updated**: March 14, 2026
