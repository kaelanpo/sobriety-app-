# Sobriety App - Project Description

## Overview
A native iOS sobriety tracking application built with SwiftUI. The app is fully self-contained with all data stored locally on the device. The project also includes a separate Node.js backend API and a React Native analysis component, but these are not currently integrated with the iOS app.

---

## iOS Application (Primary - Fully Functional)

### Architecture
- **Framework**: SwiftUI
- **Data Storage**: UserDefaults (primary), SwiftData models defined for iOS 17+ (not actively used)
- **State Management**: ObservableObject pattern with `SobrietyStore`
- **Minimum iOS**: Supports iOS 16+ (with iOS 17+ features conditionally available)

### Core Features (Implemented & Working)

#### 1. Daily Check-In System
- **Function**: `checkIn()` in `SobrietyStore`
- **Behavior**: 
  - Records daily check-ins (one per day)
  - Prevents duplicate check-ins for the same day
  - Automatically calculates streaks from check-in dates
  - Stores check-in dates as array of Date objects in UserDefaults
- **UI**: Large, prominent check-in button on main dashboard
- **Visual Feedback**: Haptic feedback on check-in, visual state changes

#### 2. Streak Tracking
- **Current Streak**: Calculated from consecutive check-in days
- **Longest Streak**: Tracks personal best
- **Algorithm**: `computeStreaks()` function handles:
  - Consecutive day calculation
  - Gap detection (streak breaks if >1 day gap)
  - Automatic recomputation on app launch
- **Display**: Shown prominently on dashboard with chain visualization

#### 3. Milestone System
- **Milestones**: 1, 3, 7, 14, 30, 60, 90, 180, 365 days
- **Auto-Detection**: `checkMilestones()` automatically detects when milestones are achieved
- **Storage**: Milestones saved with achievement dates in UserDefaults
- **Display**: 
  - Achievement cards in Analysis tab
  - Progress indicator to next milestone
  - Icons and descriptions for each milestone

#### 4. Habit/Goal Tracking
- **Full CRUD**: Create, read, update, delete habits
- **Categories**: Wellness, Fitness, Education, Support, Spirituality, Creativity, Social, Other (with emojis)
- **Frequencies**: Daily, Weekly, Monthly
- **Reset Logic**: 
  - Daily habits reset when a new day is detected (checked on view appear and when habits change)
  - Weekly habits reset when a new week is detected
  - Monthly frequency defined but reset logic not fully implemented (only daily/weekly reset)
- **Persistence**: Stored in UserDefaults as JSON
- **Default Habits**: Loads 5 default habits for first-time users
- **Progress Tracking**: Custom circular progress indicator (Circle-based, not using CircularProgressRing component) showing completion percentage and weekly progress
- **Achievement Notifications**: Custom inline toast notification when completing a habit (displays "Achievement Unlocked! +10 Recovery Points")

#### 5. Calendar View
- **Component**: `MiniCalendarView` (expandable from dashboard)
- **Features**:
  - Monthly calendar grid
  - Highlights days with check-ins
  - Shows current month with navigation to previous/next months
  - Displays count of check-ins for current month
  - Today indicator
- **Integration**: Expandable from main dashboard header

#### 6. Data Management
- **Export Functionality**: 
  - Creates JSON file with all user data
  - Includes: streaks, milestones, habits, dates
  - Uses iOS share sheet for export
  - File naming with timestamp
- **Reset Options**:
  - Mark Relapse: Resets current streak, preserves longest streak
  - Reset All Data: Clears all data (with confirmation dialog)
- **Data Validation**: Error handling and data validation on load

#### 7. Notifications
- **Implementation**: `NotificationManager` class + inline notification code in Settings
- **Features**:
  - Daily check-in reminders (configurable time)
  - Permission request handling
  - Toggle on/off in Settings
  - Error handling for denied permissions
- **Scheduling**: Uses `UNCalendarNotificationTrigger` for daily repeats

#### 8. Settings & Resources
- **Profile Section**: Displays current streak
- **Crisis Resources**: 
  - Emergency contact cards (National Suicide Prevention Lifeline, SAMHSA, Crisis Text Line)
  - Direct phone number dialing
  - Crisis guidance information
- **Recovery Resources**: Information cards for support resources
- **Legal**: Privacy Policy and Terms of Service views (static content)
- **Contact Support**: Email composition with pre-filled user data

#### 9. UI Components
- **Design System**: Comprehensive design tokens (colors, spacing, typography, radius)
- **Color Palette**: Cream background, purple gradients, mint accents
- **Custom Components**:
  - `SoftCard`: Card component with shadow
  - `PrimaryButtonStyle`: Gradient button style
  - `DailyActionHub`: Unified check-in interface
  - `DailyAffirmationCard`: Motivational quote display
  - `MiniCalendarView`: Calendar component
- **Animations**: Spring animations, transitions, shimmer effects

#### 10. Motivational Content
- **Quotes**: 10 built-in motivational quotes
- **Display**: Rotating quotes on dashboard (based on day of year for consistency)
- **Affirmations**: Daily affirmation card with encouragement messages

### Data Models (Implemented)
- `Milestone`: Codable struct with achievement tracking
- `Habit`: Codable struct with category and frequency
- `CheckIn`: SwiftData model (iOS 17+, defined but primary storage is UserDefaults)
- `Goal`: SwiftData model (iOS 17+, defined but not actively used)
- `ExportData`: Codable struct for data export

### Tab Navigation
1. **Home** (SobrietyDashboard): Main dashboard with check-in, calendar, affirmations
2. **Goals** (HabitTrackingView): Habit/goal tracking and progress
3. **Analysis** (GamificationView): Milestones, stats, insights display
4. **More** (SettingsView): Settings, data management, resources

### Conditional Features
- **iOS 18 Live Activities**: Code exists for Dynamic Island/Lock Screen display (conditional compilation, requires iOS 18+)
- **SwiftData**: Models defined but app primarily uses UserDefaults for compatibility

---

## Backend API (Separate - Not Integrated)

### Structure
- **Framework**: Node.js with Express.js
- **Database**: Mongoose (MongoDB) - models defined
- **Purpose**: Analysis service for check-in data

### Components
1. **API Route** (`backend/api/analysis.js`): 
   - `GET /:userId` endpoint
   - Returns analysis data for a user

2. **Model** (`backend/models/CheckIn.js`):
   - Mongoose schema with userId, date, status (clean/relapse/skipped), checkInTime

3. **Service** (`backend/services/AnalysisService.js`):
   - Streak calculation algorithms
   - Trend data generation (90-day weekly buckets)
   - Insights generation (strongest time of day, trigger day patterns)
   - Milestone tracking logic

### Status
- **Not Connected**: iOS app does not make API calls
- **Standalone**: Backend is a separate service that could be integrated in the future

---

## React Native Component (Separate - Mock Data Only)

### Component
- **File**: `frontend/AnalysisScreen.js`
- **Framework**: React Native with Victory Native charts
- **Status**: UI complete but uses hardcoded mock data
- **Features Displayed**:
  - Progress visualization
  - Streak display
  - Milestone cards
  - Trend charts
  - Insights display

### Status
- **Not Integrated**: Not connected to iOS app or backend
- **Mock Data**: All data is hardcoded, no real data integration

---

## Additional UI Components (Defined but Not Used)

These components exist in the codebase but are **not currently used** in any main views. They only appear in their own preview code:
- `CircularProgressRing`: Animated circular progress indicator (not used - HabitTrackingView uses custom Circle-based progress)
- `ToastView`: Toast notification component (not used - HabitTrackingView uses custom inline toast)
- `InsightMetric`: Metric display component (not used)
- `ActionButton`: Action button component (not used)
- `FilterChip`: Filter chip component (not used)

---

## Technical Stack

### iOS App
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Data Persistence**: UserDefaults (primary), SwiftData (iOS 17+ models defined)
- **Notifications**: UserNotifications framework
- **Conditional**: ActivityKit (iOS 18+), WidgetKit (iOS 18+)

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Analysis**: Custom date/streak calculation algorithms

### Frontend Component
- **Framework**: React Native
- **Charts**: Victory Native
- **Status**: UI only, no data integration

---

## Data Flow

### iOS App (Current Implementation)
1. User opens app → `SobrietyStore` loads data from UserDefaults
2. User checks in → `checkIn()` saves to UserDefaults, recalculates streaks
3. Streaks computed → From check-in dates array on app launch and after check-ins
4. Milestones checked → Automatically when streak reaches milestone days
5. Habits tracked → Stored separately in UserDefaults, reset based on frequency
6. Data export → Generates JSON file from all UserDefaults data

### No Network Layer
- All data is local
- No API integration
- No cloud sync
- No backend communication

---

## Project Status Summary

### ✅ Fully Working
- iOS app with complete UI and functionality
- Daily check-in system
- Streak calculation and tracking
- Milestone system
- Habit/goal tracking with persistence
- Calendar view
- Data export
- Notifications
- Settings and resources

### ⚠️ Partially Implemented
- SwiftData models (defined but not primary storage)
- iOS 18 Live Activities (code exists, conditional)
- Backend API (exists but not connected)
- React Native component (UI only, mock data)

### ❌ Not Implemented
- Backend integration with iOS app
- Cloud sync
- Reflection/journal feature (marked as "Future" in code)
- Real data integration for React Native component

---

## Key Files

### iOS App Core
- `SobrietyApp/Test_CursorApp.swift` - App entry point
- `SobrietyApp/ContentView.swift` - Main tab navigation
- `SobrietyApp/SobrietyStore.swift` - State management and data persistence
- `SobrietyApp/SobrietyDashboard.swift` - Main dashboard view
- `SobrietyApp/HabitTrackingView.swift` - Habit tracking interface
- `SobrietyApp/GamificationView.swift` - Analysis/progress view
- `SobrietyApp/SettingsView.swift` - Settings and resources
- `SobrietyApp/Models.swift` - Data models
- `SobrietyApp/DesignSystem.swift` - Design tokens and components
- `SobrietyApp/NotificationManager.swift` - Notification handling

### Backend (Separate)
- `backend/api/analysis.js` - API route
- `backend/models/CheckIn.js` - Database model
- `backend/services/AnalysisService.js` - Analysis logic

### Frontend Component (Separate)
- `frontend/AnalysisScreen.js` - React Native analysis UI


