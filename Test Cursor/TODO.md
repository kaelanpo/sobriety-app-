# TODO List - Sobriety App

## 🐛 Bugs / Incomplete Features

### High Priority

1. **Monthly Habit Reset Logic Missing**
   - **Issue**: Users can select "Monthly" frequency for habits, but reset logic only handles daily/weekly
   - **Impact**: Monthly habits never auto-reset, breaking expected behavior
   - **Location**: `SobrietyApp/HabitTrackingView.swift` - `checkAndResetHabits()` function
   - **Fix**: Add monthly reset check using `calendar.isDate(lastResetDate, equalTo: now, toGranularity: .month)`
   - **Status**: ⚠️ Bug - Feature partially implemented

2. **Unused UI Components**
   - **Issue**: Several components defined but never used in main views:
     - `CircularProgressRing.swift` - Not used (custom Circle-based progress used instead)
     - `ToastView.swift` - Not used (custom inline toast used in HabitTrackingView)
     - `InsightMetric.swift` - Not used
     - `ActionButton.swift` - Not used
     - `FilterChip.swift` - Not used
   - **Impact**: Dead code, potential confusion, maintenance burden
   - **Options**:
     - Remove unused components if not needed
     - OR integrate them where appropriate (e.g., use ToastView instead of custom toast)
   - **Status**: 🧹 Code Cleanup

## 🔗 Integration Opportunities

### Medium Priority

3. **Backend API Integration**
   - **Current**: Backend API exists separately but iOS app is fully local
   - **Components**:
     - `backend/api/analysis.js` - Analysis endpoint
     - `backend/services/AnalysisService.js` - Streak/trend/insight calculations
     - `backend/models/CheckIn.js` - MongoDB model
   - **Value**: Could enable cloud sync, multi-device support, advanced analytics
   - **Decision Needed**: 
     - Is cloud sync a requirement?
     - Should this remain local-only for privacy?
   - **Status**: 💡 Feature Enhancement (Optional)

4. **React Native Component Integration**
   - **Current**: `frontend/AnalysisScreen.js` uses hardcoded mock data
   - **Value Assessment**:
     - ✅ **High Value** if: Planning React Native app, need cross-platform, or want to reuse analysis UI
     - ❌ **Low Value** if: iOS-only project, just a demo/prototype
   - **Integration Options**:
     - Connect to backend API for real data
     - Connect to iOS app via shared backend
     - Keep as demo/prototype
   - **Status**: 🤔 Decision Needed

## 🚀 Feature Enhancements

### Low Priority (Nice to Have)

5. **Reflection/Journal Feature**
   - **Current**: Button exists in `DailyAffirmationCard` but marked as "Future" in comment
   - **Location**: `SobrietyApp/SobrietyDashboard.swift` line 303
   - **Status**: 💭 Future Feature

6. **SwiftData Migration**
   - **Current**: SwiftData models defined but app uses UserDefaults primarily
   - **Models**: `CheckIn`, `Goal` (iOS 17+)
   - **Value**: Better data management, relationships, querying
   - **Consideration**: Would require iOS 17+ minimum, breaking change
   - **Status**: 💭 Future Enhancement

7. **iOS 18 Live Activities Testing**
   - **Current**: Code exists but conditional on iOS 18+
   - **Location**: `SobrietyApp/SobrietyDashboard.swift` - `updateLiveActivity()` function
   - **Status**: ✅ Code Complete - Needs Testing on iOS 18+ devices

8. **Habit Progress Display**
   - **Current**: Only shows daily habits in main list
   - **Enhancement**: Could show weekly/monthly habits separately or with different UI
   - **Status**: 💡 Enhancement Idea

## 📋 Code Quality

9. **Error Handling Review**
   - Review error handling in:
     - Data persistence (UserDefaults save/load)
     - Notification scheduling
     - Data export
   - **Status**: 🔍 Code Review

10. **Testing**
    - Unit tests for streak calculation logic
    - Unit tests for milestone detection
    - UI tests for critical flows (check-in, habit tracking)
    - **Status**: 🧪 Testing Needed

## 📝 Documentation

11. **API Documentation**
    - Document backend API endpoints if planning integration
    - **Status**: 📚 Documentation

12. **Architecture Decision Records**
    - Document why UserDefaults over SwiftData
    - Document why local-only vs cloud sync
    - **Status**: 📚 Documentation

---

## Priority Recommendations

### Must Fix (Before Release)
1. ✅ Monthly habit reset logic (#1)

### Should Consider
2. 🧹 Remove or integrate unused components (#2)
3. 🤔 Decide on React Native component future (#4)

### Optional
4. 💡 Backend integration if cloud sync needed (#3)
5. 💭 Future features as roadmap items (#5, #6)

---

## Quick Wins

- **Fix monthly reset**: ~15 minutes (add 3-4 lines to reset logic)
- **Remove unused components**: ~30 minutes (if not needed)
- **Use ToastView component**: ~20 minutes (replace custom toast)

