# GitHub-Style Reading Heatmap Implementation Plan

## Overview

This document outlines the implementation plan for adding a GitHub-style contribution heatmap to the Thaqalayn app's ProgressDashboardView. The heatmap will visualize a user's Quranic reading activity over the past year, replacing/enhancing the current basic 7-day weekly calendar.

## Motivation

**Current State**: Simple 7-day weekly calendar with checkmarks indicating any reading activity
**Desired State**: Full-year heatmap (52 weeks × 7 days) with color intensity showing volume of verses read

**Benefits**:
- **Visual Motivation**: Encourages consistent daily reading habits
- **Gamification**: Users can "fill the calendar" like GitHub contributions
- **Spiritual Journey**: Visualizes progress over time
- **Data-Rich**: More informative than binary checkmarks
- **Brand Differentiation**: Unique among Islamic apps

## Current Infrastructure Analysis

### Existing Data (ProgressManager.swift)

The app already tracks all necessary data:

```swift
// VerseProgress model stores each verse read with timestamp
struct VerseProgress: Codable, Identifiable {
    var id: UUID
    var surahNumber: Int
    var verseNumber: Int
    var verseKey: String  // e.g., "1:5"
    var readDate: Date    // ✅ KEY: Timestamp for heatmap
    var isRead: Bool
}

// Already computed aggregations
func getWeeklyProgress() -> [Int]  // Last 7 days
func getMonthlyProgress() -> [Int] // Last 30 days
```

### Existing UI (ProgressDashboardView.swift)

Current layout structure:
```
[Total Sawab Hero Card]
[Current Streak Hero Card]
[Quick Stats Grid - 2×2]
[Weekly Calendar - 7 circles] ← **TARGET FOR REPLACEMENT**
[Badge Collection Grid]
[Recent Activity List]
```

## Technical Implementation Plan

### Phase 1: Data Layer Enhancement

#### 1.1 Add Heatmap Data Methods to ProgressManager.swift

```swift
// New methods to add:

/// Returns verse counts aggregated by date for the past year
func getYearlyHeatmapData() -> [Date: Int] {
    // 1. Get all verseProgress entries
    // 2. Filter to last 365 days
    // 3. Group by date (normalize to midnight)
    // 4. Count verses per day
    // 5. Return dictionary: [Date: verseCount]
}

/// Flexible date range query
func getHeatmapData(startDate: Date, endDate: Date) -> [Date: Int] {
    // Same as above but with custom date range
    // Useful for monthly/quarterly views
}

/// Get verse details for a specific date
func getVersesRead(on date: Date) -> [VerseProgress] {
    // Filter verseProgress to specific date
    // Used for tap interaction (show verses read that day)
}
```

**Implementation Notes**:
- Use `Calendar.current.startOfDay(for: date)` to normalize dates
- Consider caching for performance (365 days of data)
- Use `Dictionary(grouping:by:)` for efficient aggregation

#### 1.2 Define Color Intensity Thresholds

```swift
enum HeatmapIntensity: Int, CaseIterable {
    case none = 0        // No verses read (0)
    case low = 1         // 1-5 verses
    case medium = 2      // 6-15 verses
    case high = 3        // 16-30 verses
    case veryHigh = 4    // 31+ verses

    static func level(forVerseCount count: Int) -> HeatmapIntensity {
        switch count {
        case 0: return .none
        case 1...5: return .low
        case 6...15: return .medium
        case 16...30: return .high
        default: return .veryHigh
        }
    }
}
```

### Phase 2: UI Component Creation

#### 2.1 Create ReadingHeatmapView.swift

**File Location**: `Thaqalayn/Views/Components/ReadingHeatmapView.swift`

**Component Structure**:
```swift
struct ReadingHeatmapView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var progressManager: ProgressManager

    @State private var heatmapData: [Date: Int] = [:]
    @State private var selectedDate: Date?
    @State private var showingDateDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            heatmapHeader

            // Legend
            heatmapLegend

            // Grid (52 weeks × 7 days)
            heatmapGrid
        }
        .onAppear {
            loadHeatmapData()
        }
        .sheet(isPresented: $showingDateDetail) {
            dateDetailSheet
        }
    }
}
```

#### 2.2 Grid Layout Implementation

```swift
private var heatmapGrid: some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 3) {
            // Day labels (Mon, Wed, Fri)
            dayLabelsColumn

            // 52 weeks
            ForEach(0..<52, id: \.self) { weekIndex in
                weekColumn(weekIndex: weekIndex)
            }
        }
    }
}

private func weekColumn(weekIndex: Int) -> some View {
    VStack(spacing: 3) {
        // Month marker (if first day of month)
        monthMarker(weekIndex: weekIndex)

        // 7 days
        ForEach(0..<7, id: \.self) { dayIndex in
            dayCell(weekIndex: weekIndex, dayIndex: dayIndex)
        }
    }
}

private func dayCell(weekIndex: Int, dayIndex: Int) -> some View {
    // Calculate date for this cell
    let date = dateForCell(weekIndex: weekIndex, dayIndex: dayIndex)
    let verseCount = heatmapData[date] ?? 0
    let intensity = HeatmapIntensity.level(forVerseCount: verseCount)

    return Rectangle()
        .fill(colorForIntensity(intensity))
        .frame(width: 12, height: 12)
        .cornerRadius(2)
        .onTapGesture {
            selectedDate = date
            showingDateDetail = true
        }
}
```

#### 2.3 Theme-Adaptive Color Schemes

```swift
private func colorForIntensity(_ intensity: HeatmapIntensity) -> Color {
    switch themeManager.selectedTheme {
    case .modernDark:
        return modernDarkColors(intensity)
    case .modernLight:
        return modernLightColors(intensity)
    case .classicLight:
        return classicLightColors(intensity)
    case .sepia:
        return sepiaColors(intensity)
    }
}

// Green gradient (GitHub-style) for modern themes
private func modernDarkColors(_ intensity: HeatmapIntensity) -> Color {
    switch intensity {
    case .none: return Color.gray.opacity(0.1)
    case .low: return Color.green.opacity(0.3)
    case .medium: return Color.green.opacity(0.5)
    case .high: return Color.green.opacity(0.7)
    case .veryHigh: return Color.green.opacity(0.9)
    }
}

private func modernLightColors(_ intensity: HeatmapIntensity) -> Color {
    switch intensity {
    case .none: return Color.gray.opacity(0.1)
    case .low: return Color(red: 0.8, green: 0.95, blue: 0.8)
    case .medium: return Color(red: 0.5, green: 0.85, blue: 0.5)
    case .high: return Color(red: 0.2, green: 0.7, blue: 0.2)
    case .veryHigh: return Color(red: 0.1, green: 0.5, blue: 0.1)
    }
}

// Gold/amber gradient for classic themes
private func classicLightColors(_ intensity: HeatmapIntensity) -> Color {
    switch intensity {
    case .none: return Color.gray.opacity(0.1)
    case .low: return Color(red: 1.0, green: 0.95, blue: 0.8)
    case .medium: return Color(red: 1.0, green: 0.85, blue: 0.5)
    case .high: return Color(red: 0.9, green: 0.7, blue: 0.3)
    case .veryHigh: return Color(red: 0.8, green: 0.55, blue: 0.1)
    }
}

// Warm sepia tones
private func sepiaColors(_ intensity: HeatmapIntensity) -> Color {
    switch intensity {
    case .none: return Color(red: 0.95, green: 0.9, blue: 0.85).opacity(0.3)
    case .low: return Color(red: 0.9, green: 0.8, blue: 0.7)
    case .medium: return Color(red: 0.8, green: 0.65, blue: 0.5)
    case .high: return Color(red: 0.7, green: 0.5, blue: 0.35)
    case .veryHigh: return Color(red: 0.6, green: 0.4, blue: 0.25)
    }
}
```

#### 2.4 Interactive Features

**Color Legend**:
```swift
private var heatmapLegend: some View {
    HStack(spacing: 4) {
        Text("Less")
            .font(.caption2)
            .foregroundColor(themeManager.secondaryText)

        ForEach(HeatmapIntensity.allCases, id: \.self) { intensity in
            Rectangle()
                .fill(colorForIntensity(intensity))
                .frame(width: 10, height: 10)
                .cornerRadius(2)
        }

        Text("More")
            .font(.caption2)
            .foregroundColor(themeManager.secondaryText)
    }
}
```

**Date Detail Sheet**:
```swift
private var dateDetailSheet: some View {
    VStack(spacing: 16) {
        // Header
        Text(selectedDate?.formatted(date: .long, time: .omitted) ?? "")
            .font(.headline)

        // Verse count
        if let date = selectedDate {
            let count = heatmapData[date] ?? 0
            Text("\(count) verse\(count == 1 ? "" : "s") read")
                .font(.title2)
                .foregroundColor(themeManager.accent)

            // List of verses read
            if count > 0 {
                List {
                    ForEach(progressManager.getVersesRead(on: date)) { verse in
                        Text("\(verse.verseKey)")
                            .font(.body)
                    }
                }
            } else {
                Text("No reading activity")
                    .foregroundColor(themeManager.secondaryText)
            }
        }
    }
    .padding()
    .presentationDetents([.medium])
}
```

### Phase 3: Integration into ProgressDashboardView

#### 3.1 Replace Weekly Calendar Section

**Location**: `Thaqalayn/Views/ProgressDashboardView.swift`

**Current Code** (to be replaced):
```swift
// Weekly Calendar (current implementation)
VStack(alignment: .leading, spacing: 8) {
    Text("This Week")
        .font(.headline)
        .foregroundColor(themeManager.primaryText)

    HStack(spacing: 12) {
        ForEach(0..<7) { index in
            VStack(spacing: 4) {
                Text(weekDayLabel(index))
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)

                Circle()
                    .fill(hasReadingOnDay(index) ? themeManager.accent : Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.caption)
                            .opacity(hasReadingOnDay(index) ? 1 : 0)
                    )
            }
        }
    }
}
```

**New Code**:
```swift
// Reading Heatmap (year-long view)
VStack(alignment: .leading, spacing: 12) {
    HStack {
        Text("Reading Activity")
            .font(.headline)
            .foregroundColor(themeManager.primaryText)

        Spacer()

        // Optional: Toggle between views
        Menu {
            Button("Last 7 Days") { viewMode = .week }
            Button("Last Year") { viewMode = .year }
        } label: {
            Image(systemName: "calendar")
                .foregroundColor(themeManager.accent)
        }
    }

    if viewMode == .year {
        ReadingHeatmapView()
            .environmentObject(themeManager)
            .environmentObject(progressManager)
    } else {
        // Keep old weekly view as option
        weeklyCalendarView
    }
}
```

### Phase 4: Performance Optimization

#### 4.1 Data Caching Strategy

```swift
class ProgressManager: ObservableObject {
    // Add cached heatmap data
    private var cachedHeatmapData: [Date: Int]?
    private var lastCacheUpdate: Date?

    func getYearlyHeatmapData() -> [Date: Int] {
        // Check cache freshness (5 minute TTL)
        if let cached = cachedHeatmapData,
           let lastUpdate = lastCacheUpdate,
           Date().timeIntervalSince(lastUpdate) < 300 {
            return cached
        }

        // Recompute and cache
        let data = computeHeatmapData()
        cachedHeatmapData = data
        lastCacheUpdate = Date()
        return data
    }

    private func computeHeatmapData() -> [Date: Int] {
        // Aggregate verseProgress by day
        let calendar = Calendar.current
        var result: [Date: Int] = [:]

        for verse in verseProgress {
            let day = calendar.startOfDay(for: verse.readDate)
            result[day, default: 0] += 1
        }

        return result
    }
}
```

#### 4.2 Lazy Loading for Large Datasets

```swift
// In ReadingHeatmapView
@State private var isLoading = false

private func loadHeatmapData() {
    isLoading = true

    // Async loading to avoid blocking UI
    DispatchQueue.global(qos: .userInitiated).async {
        let data = progressManager.getYearlyHeatmapData()

        DispatchQueue.main.async {
            self.heatmapData = data
            self.isLoading = false
        }
    }
}
```

### Phase 5: Accessibility & Localization

#### 5.1 VoiceOver Support

```swift
private func dayCell(weekIndex: Int, dayIndex: Int) -> some View {
    let date = dateForCell(weekIndex: weekIndex, dayIndex: dayIndex)
    let verseCount = heatmapData[date] ?? 0

    return Rectangle()
        // ... existing code ...
        .accessibilityLabel("\(date.formatted(date: .long, time: .omitted))")
        .accessibilityValue("\(verseCount) verse\(verseCount == 1 ? "" : "s") read")
        .accessibilityHint("Tap to see details")
}
```

#### 5.2 Dynamic Type Support

```swift
// Adjust cell size based on content size category
@Environment(\.sizeCategory) var sizeCategory

private var cellSize: CGFloat {
    switch sizeCategory {
    case .extraSmall, .small:
        return 10
    case .medium, .large:
        return 12
    case .extraLarge, .extraExtraLarge:
        return 14
    default:
        return 16
    }
}
```

## Testing Plan

### 6.1 Unit Tests

```swift
class ProgressManagerHeatmapTests: XCTestCase {
    func testGetYearlyHeatmapData() {
        // Given: Mock verse progress data
        let manager = ProgressManager()
        manager.verseProgress = mockVerseProgress()

        // When: Get heatmap data
        let data = manager.getYearlyHeatmapData()

        // Then: Verify aggregation
        XCTAssertEqual(data.count, 365) // Full year
        XCTAssertEqual(data[today], 10) // Expected count
    }

    func testHeatmapIntensityLevels() {
        XCTAssertEqual(HeatmapIntensity.level(forVerseCount: 0), .none)
        XCTAssertEqual(HeatmapIntensity.level(forVerseCount: 3), .low)
        XCTAssertEqual(HeatmapIntensity.level(forVerseCount: 10), .medium)
        XCTAssertEqual(HeatmapIntensity.level(forVerseCount: 20), .high)
        XCTAssertEqual(HeatmapIntensity.level(forVerseCount: 50), .veryHigh)
    }
}
```

### 6.2 Manual Testing Checklist

- [ ] **Visual Testing**
  - [ ] Verify heatmap renders correctly in all 4 themes
  - [ ] Check color contrast for accessibility (WCAG AA)
  - [ ] Test on iPhone SE (small screen) and iPhone 16 Pro Max (large screen)
  - [ ] Verify horizontal scrolling works smoothly
  - [ ] Check month markers align correctly

- [ ] **Data Accuracy**
  - [ ] Empty state (no reading history)
  - [ ] Sparse data (few days with activity)
  - [ ] Dense data (daily reading for months)
  - [ ] Edge cases (leap years, timezone changes)

- [ ] **Interactions**
  - [ ] Tap on cell opens detail sheet
  - [ ] Detail sheet shows correct verses
  - [ ] Dismiss gesture works
  - [ ] VoiceOver navigation

- [ ] **Performance**
  - [ ] Load time with 365 days of data
  - [ ] Scroll performance
  - [ ] Memory usage
  - [ ] Cache invalidation works correctly

### 6.3 Simulator Testing

```bash
# Build and run on iPhone 16
build_run_sim({
  projectPath: "Thaqalayn.xcodeproj",
  scheme: "Thaqalayn",
  simulatorName: "iPhone 16"
})

# Navigate to: Settings → Progress Dashboard → Reading Activity
```

## Future Enhancements

### 7.1 Islamic Calendar Integration

- Highlight special Islamic dates (Ramadan, Laylat al-Qadr, etc.)
- Show dual calendar labels (Gregorian + Hijri)
- Special color for sacred months

### 7.2 Streak Visualization

- Highlight current streak with border/glow effect
- Show longest streak period
- Animate streak milestones

### 7.3 Social Sharing

- Export heatmap as image
- Share on social media for da'wah
- Privacy controls (anonymize data)

### 7.4 Advanced Analytics

- Weekly/monthly comparison view
- Year-over-year comparison
- Predictive streaks ("You're on track to read X verses this month!")

### 7.5 Customization Options

- User-selectable color schemes
- Adjustable intensity thresholds
- Time range selection (1 month, 3 months, 6 months, 1 year)

## Migration Notes

### Backward Compatibility

- No database schema changes required
- All data already exists in `verseProgress`
- New feature is purely additive (doesn't break existing functionality)

### Rollout Strategy

1. Implement heatmap alongside existing weekly view
2. Add toggle to switch between views
3. Collect user feedback
4. Make heatmap default view in future release
5. Keep weekly view as legacy option

## Estimated Effort

- **ProgressManager enhancements**: 2-3 hours
- **ReadingHeatmapView component**: 4-6 hours
- **Integration into ProgressDashboardView**: 1-2 hours
- **Color schemes & theme support**: 2-3 hours
- **Testing & refinement**: 3-4 hours
- **Total**: 12-18 hours

## Dependencies

- No external libraries required
- Uses native SwiftUI components
- Leverages existing ProgressManager infrastructure
- Compatible with iOS 15.0+ (current app minimum)

## Success Metrics

After implementation, measure:
- User engagement with ProgressDashboardView (view time)
- Reading streak retention (do streaks last longer?)
- User feedback/ratings mentioning the feature
- Screenshot shares on social media

## References

- GitHub Contribution Graph: https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/managing-contribution-settings-on-your-profile/viewing-contributions-on-your-profile
- Existing implementation: `ProgressManager.swift:1-300`
- Current dashboard: `ProgressDashboardView.swift:1-400`
- Theme system: `ThemeManager.swift:1-200`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-17
**Author**: Claude Code
**Status**: Ready for Implementation
