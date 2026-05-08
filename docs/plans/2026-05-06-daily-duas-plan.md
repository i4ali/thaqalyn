# Daily Duas Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ship a Daily Duas feature in the Thaqalayn iOS app — 20 short hadith-based Shia supplications, accessible via the Explore tab and Home discovery carousel, displayed in EN/AR/UR with source citations and a share action. Mirrors the existing Life Moments pattern.

**Architecture:** Static JSON-backed feature with no Supabase sync, no audio, no bookmarking in v1. New view (`DuasView`) and detail view (`DuaDetailView`) follow the same shape as `LifeMomentsView`. New singleton `DuasManager` loads `daily_duas.json` lazily. Two integration points: `ExploreView` (new row) and `DiscoveryCarousel` (new card, page count grows from 4 to 5). Situation labels, screen titles, and translations respect `CommentaryLanguageManager.selectedLanguage`.

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 15+. Xcode 16 synced folder groups (per `reference_xcode_synced_folders` memory — drop files in folders, no pbxproj edits). No external dependencies.

**Validation strategy:** No XCTest target exists in this project. Each task ends with a JSON-schema check (where applicable) plus a build via the MCP XcodeBuild tools, plus a manual simulator visual check on the affected screen. Per `feedback_no_auto_commits` memory, tasks do **not** auto-commit — the user commits at their own cadence.

**Reference design doc:** `docs/plans/2026-05-06-daily-duas-design.md`

---

## Conventions for every task below

- **File paths are absolute** from the repo root.
- **Build/run command** when needed:
  ```
  build_run_sim_name_proj({ projectPath: "Thaqalayn.xcodeproj", scheme: "Thaqalayn", simulatorName: "iPhone 17" })
  ```
- **No commits.** Stop at the verification step.
- **Per `CLAUDE.md`:** no fallback logic, no graceful degradation. Throw or surface clear errors.
- **Per `CLAUDE.md`:** default to no comments unless the WHY is non-obvious.

---

## Task 1: Add data models to QuranModels.swift

**Files:**
- Modify: `Thaqalayn/Thaqalayn/Models/QuranModels.swift` — append to end of file

**Step 1: Read the end of the file to find the insertion point**

Read the last ~30 lines of `Thaqalayn/Thaqalayn/Models/QuranModels.swift` to identify the final closing brace and add a clean `// MARK: - Daily Duas Models` section after the last existing model.

**Step 2: Append the new models**

Add this block at the end of the file (before any trailing newline):

```swift
// MARK: - Daily Duas Models

struct DailyDuasData: Codable {
    let duas: [DailyDua]
}

struct DailyDua: Codable, Identifiable {
    let id: String
    let situationEn: String
    let situationAr: String
    let situationUr: String
    let arabic: String
    let transliteration: String
    let translationEn: String
    let translationUr: String
    let source: String
    let category: String

    func situation(for language: CommentaryLanguage) -> String {
        switch language {
        case .arabic: return situationAr
        case .urdu: return situationUr
        default: return situationEn
        }
    }

    func translation(for language: CommentaryLanguage) -> String {
        switch language {
        case .urdu: return translationUr
        default: return translationEn
        }
    }

    var categoryIcon: String {
        switch category.lowercased() {
        case "daily": return "sun.max.fill"
        case "eating": return "fork.knife"
        case "travel": return "car.fill"
        case "worship": return "moon.stars.fill"
        case "other": return "sparkles"
        default: return "hands.sparkles.fill"
        }
    }
}
```

**Step 3: Verify build succeeds**

Run the build via the MCP XcodeBuild tool. Expected: `BUILD SUCCEEDED`. The new types are unused at this point — that's fine, they'll be referenced from later tasks.

**Step 4: Stop. Do not commit.**

---

## Task 2: Create the source-of-truth JSON for 20 duas

**Files:**
- Create: `Thaqalayn/Thaqalayn/Data/daily_duas.json`

This is the **highest-judgment task** in the plan. The content has to be authoritative or the feature isn't worth shipping. Read `docs/plans/2026-05-06-daily-duas-design.md` § "Content sourcing plan" before starting.

**Step 1: Build the situations seed list from the source image**

The 20 situations from the image (Urdu → English mapping):
1. Before eating — "Before eating" / "دعاء قبل الأكل" / "کھانا کھانے کی دعا"
2. After eating — "After eating" / "دعاء بعد الأكل" / "کھانا ختم کرنے کی دعا"
3. Before sleeping — "Before sleeping" / "دعاء قبل النوم" / "سوتے وقت کی دعا"
4. Upon waking — "Upon waking" / "دعاء عند الاستيقاظ" / "سو کر اٹھنے کی دعا"
5. Entering the bathroom — "Entering the bathroom" / "دعاء دخول الخلاء" / "بیت الخلا میں جانے کی دعا"
6. Leaving the bathroom — "Leaving the bathroom" / "دعاء الخروج من الخلاء" / "بیت الخلا سے نکلنے کی دعا"
7. Entering the home — "Entering the home" / "دعاء دخول المنزل" / "گھر میں داخل ہونے کی دعا"
8. Leaving the home — "Leaving the home" / "دعاء الخروج من المنزل" / "گھر سے نکلنے کی دعا"
9. Entering the mosque — "Entering the mosque" / "دعاء دخول المسجد" / "مسجد میں داخل ہونے کی دعا"
10. Leaving the mosque — "Leaving the mosque" / "دعاء الخروج من المسجد" / "مسجد سے نکلنے کی دعا"
11. Boarding a vehicle — "Boarding a vehicle" / "دعاء ركوب المركبة" / "سواری پر بیٹھنے کی دعا"
12. Disembarking — "Disembarking" / "دعاء النزول من المركبة" / "سواری سے اترنے کی دعا"
13. At a time of calamity — "At a time of calamity" / "دعاء عند المصيبة" / "مصیبت کے وقت کی دعا"
14. When wearing new clothes — "When wearing new clothes" / "دعاء لبس الثوب" / "لباس پہننے کی دعا"
15. When visiting the sick — "When visiting the sick" / "دعاء عيادة المريض" / "مریض کی عیادت کی دعا"
16. When drinking milk — "When drinking milk" / "دعاء شرب اللبن" / "دودھ پینے کی دعا"
17. When sighting the new moon — "When sighting the new moon" / "دعاء رؤية الهلال" / "چاند دیکھنے کی دعا"
18. When looking in the mirror — "When looking in the mirror" / "دعاء النظر في المرآة" / "آئینہ دیکھنے کی دعا"
19. When intending to fast — "When intending to fast" / "دعاء نية الصوم" / "روزہ رکھنے کی دعا"
20. At iftar — "At iftar" / "دعاء الإفطار" / "روزہ افطار کرنے کی دعا"

**Step 2: For each entry, source the Arabic + transliteration + translations + citation**

For each of the 20 situations:

1. Search authoritative Shia sources in this priority order:
   - **al-Kafi** (Kulayni) — primary hadith source
   - **Mafatih al-Jinan** (Sheikh Abbas Qummi) — comprehensive dua compendium
   - **Wasail al-Shia** (Hurr al-Amili)
   - **Sahifa Sajjadiyya** — where applicable
2. Capture:
   - Full Arabic text **with diacritics** (sukun, fatha, kasra, damma, shadda, tanwin where present)
   - Latin transliteration in **ALA-LC** style, applied consistently across all 20
   - English translation — prefer Ansariyan / al-islam.org / duas.org wording, lightly normalized
   - Urdu translation — prefer popular Urdu Mafatih edition wording
   - Source citation — book + chapter or vol:page (e.g., `"al-Kafi 6:294"`, `"Mafatih al-Jinan, Bab al-Du'a"`)
3. Cross-check the Arabic against a second source where possible (especially for ##16, 18 which have weaker canonical forms).
4. Assign one of these categories: `daily | eating | travel | worship | other`
   - Suggested mapping: 1,2,16 → eating; 3,4,5,6,7,8,14,18 → daily; 9,10,11,12 → travel (mosque + vehicle); 13,15,17,19,20 → worship/other

**Step 3: Handle gaps honestly**

If a strong source cannot be found for one or two entries (most likely candidates: #16 milk, #18 mirror), drop them. Per the design doc, shipping with 18 or 19 is acceptable. Do **not** substitute or fabricate citations.

**Step 4: Write the file**

Path: `Thaqalayn/Thaqalayn/Data/daily_duas.json`

Schema (one entry shown — repeat for all 20):

```json
{
  "duas": [
    {
      "id": "1",
      "situationEn": "Before eating",
      "situationAr": "دعاء قبل الأكل",
      "situationUr": "کھانا کھانے کی دعا",
      "arabic": "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ",
      "transliteration": "Bismillāhi wa ʿalā barakati'llāh",
      "translationEn": "In the name of Allah, and upon the blessing of Allah.",
      "translationUr": "اللہ کے نام سے اور اللہ کی برکت سے۔",
      "source": "al-Kafi 6:294",
      "category": "eating"
    }
  ]
}
```

**Note on the example above:** the Arabic, transliteration, and source for entry #1 are illustrative starters — the implementer must independently verify against the source before committing to them.

**Step 5: Validate the JSON file structurally**

Run from the repo root:

```bash
python3 -c "
import json, sys
with open('Thaqalayn/Thaqalayn/Data/daily_duas.json') as f:
    data = json.load(f)
required = {'id','situationEn','situationAr','situationUr','arabic','transliteration','translationEn','translationUr','source','category'}
allowed_categories = {'daily','eating','travel','worship','other'}
duas = data['duas']
errors = []
ids = set()
for i, d in enumerate(duas):
    missing = required - set(d.keys())
    if missing:
        errors.append(f'#{i+1} missing fields: {missing}')
    if d['id'] in ids:
        errors.append(f'#{i+1} duplicate id {d[\"id\"]}')
    ids.add(d['id'])
    if d.get('category') not in allowed_categories:
        errors.append(f'#{i+1} bad category {d.get(\"category\")}')
    for f_ in ['arabic','translationEn','translationUr','transliteration','source']:
        if not d.get(f_, '').strip():
            errors.append(f'#{i+1} empty {f_}')
print(f'{len(duas)} duas')
if errors:
    print('ERRORS:')
    for e in errors: print(' -', e)
    sys.exit(1)
print('OK')
"
```

Expected: `OK` and a count of 18, 19, or 20.

**Step 6: Verify build succeeds**

Run the build. The JSON file is bundled automatically via Xcode 16 synced folders — no project file edits needed. Expected: `BUILD SUCCEEDED`.

**Step 7: Stop. Do not commit.**

---

## Task 3: Create DuasManager service

**Files:**
- Create: `Thaqalayn/Thaqalayn/Services/DuasManager.swift`

**Step 1: Write the file**

```swift
//
//  DuasManager.swift
//  Thaqalayn
//
//  Loads the 20-entry daily_duas.json bundle and exposes it for SwiftUI views.
//

import Foundation
import Combine

@MainActor
class DuasManager: ObservableObject {
    static let shared = DuasManager()

    @Published var duas: [DailyDua] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadDuas()
    }

    func loadDuas() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "daily_duas", withExtension: "json") else {
            errorMessage = "Could not find daily_duas.json"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DailyDuasData.self, from: data)
            self.duas = decoded.duas
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to load daily duas: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
```

Notes:
- `@MainActor` matches the project pattern (`BookmarkManager`, etc.).
- Synchronous assignment is correct because `@MainActor` + main-thread call site = no need for `DispatchQueue.main.async`.
- No fallback logic per `CLAUDE.md` — the only "graceful" path is to surface `errorMessage` so the UI can display the existing `ErrorSection`.

**Step 2: Verify build succeeds**

Run the build. Expected: `BUILD SUCCEEDED`.

**Step 3: Stop. Do not commit.**

---

## Task 4: Create DuasView (list screen)

**Files:**
- Create: `Thaqalayn/Thaqalayn/Views/DuasView.swift`

**Step 1: Read LifeMomentsView for layout reference**

Read `Thaqalayn/Thaqalayn/Views/LifeMomentsView.swift` end-to-end. We are mirroring its structure with three deltas: language-driven title/subtitle, language-driven row labels, and RTL flip when the language is Urdu or Arabic.

**Step 2: Write the file**

```swift
//
//  DuasView.swift
//  Thaqalayn
//
//  Daily duas list — short hadith-based supplications for everyday occasions.
//

import SwiftUI

struct DuasView: View {
    @StateObject private var duasManager = DuasManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDua: DailyDua?

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    headerView

                    if duasManager.isLoading {
                        LoadingSection()
                    } else if let error = duasManager.errorMessage {
                        ErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(duasManager.duas) { dua in
                                    NavigationLink(destination: DuaDetailView(dua: dua)) {
                                        DuaCard(dua: dua)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .environment(\.layoutDirection,
                                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(themeManager.colorScheme)
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizedTitle)
                        .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32,
                                      weight: .bold,
                                      design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                        .foregroundColor(themeManager.primaryText)

                    Text(localizedSubtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "الأدعية اليومية"
        case .urdu: return "روزمرہ کی دعائیں"
        default: return "Daily Duas"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "20 دعاءً قصيرًا للحظات اليومية"
        case .urdu: return "روزمرہ کے لمحات کے لیے 20 مختصر دعائیں"
        default: return "20 short supplications for everyday moments"
        }
    }
}

struct DuaCard: View {
    let dua: DailyDua
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)

                Image(systemName: dua.categoryIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dua.situation(for: languageManager.selectedLanguage))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(20)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeManager.floatingOrbColors[0].opacity(0.5),
                                        themeManager.floatingOrbColors[1].opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    DuasView()
}
```

Notes:
- Reuses `LoadingSection` and `ErrorSection` from `LifeMomentsView.swift` (they are public structs in that file).
- Reuses `AdaptiveModernBackground` (same as LifeMoments).
- `buttonStyle(.plain)` keeps the row tappable as a `NavigationLink` without the default blue button styling.
- The `.environment(\.layoutDirection, ...)` flip is applied to the rows and the header so the icon ends up on the right and chevron on the left in Urdu/Arabic mode.

**Step 3: Verify build succeeds**

Run the build. Expected: `BUILD SUCCEEDED`. (`DuaDetailView` is referenced but doesn't exist yet — the build will FAIL on this task. That's expected; resolve it by completing Task 5.)

**Step 4: Skip the build until Task 5. Do not commit.**

(If you want to verify visually before continuing, comment out the `NavigationLink(destination: DuaDetailView(dua: dua))` line and replace with a no-op `Button(action: {}) { DuaCard(dua: dua) }`, build, sanity-check, then revert. Optional.)

---

## Task 5: Create DuaDetailView

**Files:**
- Create: `Thaqalayn/Thaqalayn/Views/DuaDetailView.swift`

**Step 1: Write the file**

```swift
//
//  DuaDetailView.swift
//  Thaqalayn
//
//  Per-dua detail screen: Arabic + transliteration + translation + source + share.
//

import SwiftUI

struct DuaDetailView: View {
    let dua: DailyDua
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    arabicSection
                    transliterationSection
                    translationSection
                    sourceSection
                    shareSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dua.situation(for: languageManager.selectedLanguage))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.leading)

            categoryPill
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    private var categoryPill: some View {
        Text(dua.category.capitalized)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(themeManager.accentColor.opacity(0.15))
            )
    }

    private var arabicSection: some View {
        Text(dua.arabic)
            .font(.system(size: 28, weight: .regular))
            .foregroundColor(themeManager.primaryText)
            .multilineTextAlignment(.center)
            .lineSpacing(12)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(themedCardBackground)
            .environment(\.layoutDirection, .rightToLeft)
            .textSelection(.enabled)
    }

    private var transliterationSection: some View {
        Text(dua.transliteration)
            .font(.system(size: 16, weight: .regular, design: .serif))
            .italic()
            .foregroundColor(themeManager.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
            .textSelection(.enabled)
    }

    private var translationSection: some View {
        let language = languageManager.selectedLanguage
        let translation = dua.translation(for: language)
        let isRTL = language == .urdu

        return Text(translation)
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(themeManager.primaryText)
            .multilineTextAlignment(isRTL ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
            .padding(20)
            .background(themedCardBackground)
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
            .textSelection(.enabled)
    }

    private var sourceSection: some View {
        HStack {
            Spacer()
            Text("Source: \(dua.source)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
            Spacer()
        }
        .padding(.top, 4)
    }

    private var shareSection: some View {
        ShareLink(item: shareText) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(themeManager.accentGradient)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
            )
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private var shareText: String {
        let lang = languageManager.selectedLanguage
        return """
        \(dua.situation(for: lang))

        \(dua.arabic)

        \(dua.transliteration)

        \(dua.translation(for: lang))

        — Source: \(dua.source)
        Sent via Thaqalayn
        """
    }

    @ViewBuilder
    private var themedCardBackground: some View {
        if themeManager.selectedTheme == .warmInviting {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        } else {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationView {
        DuaDetailView(dua: DailyDua(
            id: "1",
            situationEn: "Before eating",
            situationAr: "دعاء قبل الأكل",
            situationUr: "کھانا کھانے کی دعا",
            arabic: "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ",
            transliteration: "Bismillāhi wa ʿalā barakati'llāh",
            translationEn: "In the name of Allah, and upon the blessing of Allah.",
            translationUr: "اللہ کے نام سے اور اللہ کی برکت سے۔",
            source: "al-Kafi 6:294",
            category: "eating"
        ))
    }
}
```

Notes:
- `textSelection(.enabled)` lets users long-press to copy any block (Arabic, transliteration, translation).
- The Arabic block always uses `.environment(\.layoutDirection, .rightToLeft)` regardless of UI language — Arabic prose is Arabic.
- The translation block flips RTL **only** in Urdu mode (Arabic mode falls back to English translation, which is LTR).
- `ShareLink` is iOS 16+. The project's deployment target is iOS 15. **If iOS 15 is still required**, replace with a `Button` that presents a `UIActivityViewController` via a `UIViewControllerRepresentable` wrapper. **Implementer must check the deployment target** in `project.pbxproj` (search `IPHONEOS_DEPLOYMENT_TARGET`) before relying on `ShareLink`. If deployment target is 16+, `ShareLink` is fine. If 15, swap to the `UIActivityViewController` wrapper.

**Step 2: Verify build succeeds**

Run the build. Expected: `BUILD SUCCEEDED`. Both `DuasView` and `DuaDetailView` are now valid.

**Step 3: Manually sanity-check via simulator**

Build and run the app. The new screens aren't reachable from any UI yet — that's fine. Just confirm there are no warnings or runtime issues at app launch.

**Step 4: Stop. Do not commit.**

---

## Task 6: Create DuasCarouselCard

**Files:**
- Create: `Thaqalayn/Thaqalayn/Views/Components/DuasCarouselCard.swift`

**Step 1: Read LifeMomentsCarouselCard for reference**

Read `Thaqalayn/Thaqalayn/Views/Components/LifeMomentsCarouselCard.swift` end-to-end.

**Step 2: Write the file**

```swift
//
//  DuasCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Daily Duas in the Discovery Carousel.
//

import SwiftUI

struct DuasCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 44, height: 44)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 6)

                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(localizedTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text(localizedSubtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            Button(action: { showFullView = true }) {
                HStack {
                    Text("Tap to explore")
                        .font(.system(size: 14, weight: .semibold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(themeManager.accentGradient)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 6)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(height: 145)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeManager.floatingOrbColors[0].opacity(0.5),
                                        themeManager.floatingOrbColors[1].opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "الأدعية اليومية"
        case .urdu: return "روزمرہ کی دعائیں"
        default: return "Daily Duas"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "20 دعاءً قصيرًا للأكل، النوم، السفر والمزيد"
        case .urdu: return "کھانا، سونا، سفر اور بہت کچھ کے لیے 20 مختصر دعائیں"
        default: return "20 short duas for daily life — eating, sleeping, travel, and more"
        }
    }
}

#Preview {
    DuasCarouselCard(showFullView: .constant(false))
}
```

**Step 2: Verify build succeeds**

Run the build. Expected: `BUILD SUCCEEDED`. The new card isn't wired up yet — that comes in Task 7.

**Step 3: Stop. Do not commit.**

---

## Task 7: Wire DuasCarouselCard into DiscoveryCarousel

**Files:**
- Modify: `Thaqalayn/Thaqalayn/Views/Components/DiscoveryCarousel.swift`

**Step 1: Add the showDuas state and place the card directly after Life Moments**

Apply these four edits to `Thaqalayn/Thaqalayn/Views/Components/DiscoveryCarousel.swift`:

**Edit 1** — add a new state variable. Find line 14 (`@State private var showLifeMoments = false`) and add a sibling line directly below it:

```swift
@State private var showLifeMoments = false
@State private var showDuas = false
@State private var showQuestions = false
```

**Edit 2** — insert the new carousel card directly after `LifeMomentsCarouselCard` and before `QuestionsCarouselCard`. The tag numbering shifts (Life Moments stays at 0; Duas becomes 1; Questions becomes 2; PropheticStories becomes 3; AhlulbaytQuran becomes 4). Replace the existing TabView body:

```swift
TabView(selection: $currentPage) {
    LifeMomentsCarouselCard(showFullView: $showLifeMoments)
        .tag(0)

    DuasCarouselCard(showFullView: $showDuas)
        .tag(1)

    QuestionsCarouselCard(showFullView: $showQuestions)
        .tag(2)

    PropheticStoriesCarouselCard(showFullView: $showPropheticStories)
        .tag(3)

    AhlulbaytQuranCarouselCard(showFullView: $showAhlulbaytQuran)
        .tag(4)
}
```

**Edit 3** — bump the page-indicator count and the auto-scroll modulo from 4 to 5:

In the `HStack(spacing: 6) { ForEach(0..<4, id: \.self) { ... } }` block, change `0..<4` to `0..<5`.

In `startAutoScroll()`, change `currentPage = (currentPage + 1) % 4` to `currentPage = (currentPage + 1) % 5`.

**Edit 4** — add the `fullScreenCover` for duas, placed directly after the Life Moments cover:

```swift
.fullScreenCover(isPresented: $showLifeMoments) {
    LifeMomentsView()
}
.fullScreenCover(isPresented: $showDuas) {
    DuasView()
}
.fullScreenCover(isPresented: $showQuestions) {
    QuestionsView()
}
```

**Step 2: Verify build succeeds**

Run the build. Expected: `BUILD SUCCEEDED`.

**Step 3: Visual sanity check on simulator**

Launch the app, go to the Home tab, swipe through the carousel. Expected:
- 5 cards now visible (Life Moments → Daily Duas → Questions → Prophetic Stories → Ahl al-Bayt in Quran)
- 5 page-indicator dots
- Tapping the Daily Duas "Tap to explore" CTA opens `DuasView` as a fullScreenCover
- The list shows all loaded duas
- Tapping a row opens the detail view with Arabic + transliteration + translation + source + share button
- Switching the commentary language (e.g., from settings) updates titles, subtitles, situation labels, and translation block on next view appearance
- All four themes (modernDark, modernLight, classicLight, sepia, warmInviting) render the new screens without visual regression

**Step 4: Stop. Do not commit.**

---

## Task 8: Wire Daily Duas entry into ExploreView

**Files:**
- Modify: `Thaqalayn/Thaqalayn/Views/ExploreView.swift`

Apply five small edits.

**Edit 1** — add `case dailyDuas` to the `ExploreDestination` enum. Find lines 87–94 and insert directly after `case lifeMoments`:

```swift
enum ExploreDestination {
    case lifeMoments
    case dailyDuas
    case propheticParallels
    case questions
    case fasting
    case propheticStories
    case ahlulbaytQuran
}
```

**Edit 2** — insert a new `ExploreItem` directly after the Life Moments item in `ExploreSection.lifeAndGuidance.items` (between line 35 closing `)` of lifeMoments item and line 36 opening of propheticParallels):

```swift
ExploreItem(
    id: "lifeMoments",
    icon: "heart.fill",
    title: "Life Moments",
    subtitle: "Find solace for any situation",
    destination: .lifeMoments
),
ExploreItem(
    id: "dailyDuas",
    icon: "hands.sparkles.fill",
    title: "Daily Duas",
    subtitle: "20 supplications for everyday moments",
    destination: .dailyDuas
),
ExploreItem(
    id: "propheticParallels",
    ...
),
```

**Edit 3** — add a `@State` flag in `ExploreView`. Insert directly after `@State private var showLifeMoments = false`:

```swift
@State private var showLifeMoments = false
@State private var showDailyDuas = false
@State private var showPropheticParallels = false
```

**Edit 4** — add a `case` for the new destination in `iconForItem(_:)`. Insert after `case .lifeMoments:` block:

```swift
case .lifeMoments:
    return themeManager.selectedTheme == .warmInviting ? "heart.fill" : "heart.fill"
case .dailyDuas:
    return "hands.sparkles.fill"
case .propheticParallels:
    return themeManager.selectedTheme == .warmInviting ? "person.2.wave.2.fill" : "person.2.wave.2.fill"
```

**Edit 5** — handle the tap and present the cover. In `handleTap(_:)`, insert after `case .lifeMoments:`:

```swift
case .lifeMoments:
    showLifeMoments = true
case .dailyDuas:
    showDailyDuas = true
case .propheticParallels:
    showPropheticParallels = true
```

And add the `fullScreenCover` directly after the Life Moments one:

```swift
.fullScreenCover(isPresented: $showLifeMoments) {
    LifeMomentsView()
}
.fullScreenCover(isPresented: $showDailyDuas) {
    DuasView()
}
.fullScreenCover(isPresented: $showPropheticParallels) {
    PropheticParallelsView()
}
```

**Note on title localization:** the `ExploreItem.title` is hardcoded English (matches existing pattern — Life Moments etc. are not localized in the explore list today). To stay consistent with the rest of `ExploreView`, leave it English here too. The localization happens *inside* `DuasView` once the user taps in. If you want full localization parity, that's a separate task across all explore items, not just duas.

**Step 2: Verify build succeeds**

Run the build. Expected: `BUILD SUCCEEDED`.

**Step 3: Visual sanity check**

Launch the app → Explore tab. Expected:
- "Daily Duas" row appears directly below "Life Moments" in the "Life & Guidance" section
- Icon `hands.sparkles.fill` rendered
- Tapping the row opens `DuasView`
- All previously-working explore items still work (Life Moments, Prophetic Parallels, Questions, Fasting, Prophetic Stories, Ahl al-Bayt)

**Step 4: Stop. Do not commit.**

---

## Task 9: Full-stack visual QA across themes and languages

**Files:** none — manual verification only.

This task catches integration regressions that the per-task simulator checks may have missed.

**Step 1: Theme matrix**

Open Settings → Theme. For each of the five themes (`modernDark`, `modernLight`, `classicLight`, `sepia`, `warmInviting`):
- Open Home → swipe to Daily Duas card → confirm card renders correctly (no clipped text, glass effect/shadow correct)
- Tap "Tap to explore" → confirm list renders
- Tap any row → confirm detail screen renders (Arabic block, transliteration, translation block, source, share button)
- Tap Share → confirm system share sheet shows the formatted text

**Step 2: Language matrix**

Open Settings → Commentary Language. For each of `en`, `ur`, `ar`:
- Home carousel: title/subtitle of the Daily Duas card switches
- Explore tab: row remains in English (this is intentional, see Task 8 note)
- DuasView title and subtitle switch language
- Each row label switches language
- RTL layout: in `ur` and `ar`, icon is on the right and chevron is on the left
- DuaDetailView header switches language; translation block content switches (English in `ar` mode by design); RTL only when `ur`
- Share text uses the active language for situation + translation; Arabic and source unchanged

**Step 3: Edge cases**

- Force-quit the app, relaunch, immediately open DuasView — confirm no race condition with `DuasManager` initialization
- Long Urdu translations — confirm no text clipping or layout overflow
- Tap multiple rows quickly — confirm no navigation stuck states
- Background → foreground while on detail screen — confirm state preserved

**Step 4: Stop. Do not commit. Hand off to user.**

---

## Done criteria

- [ ] All 9 tasks complete, build green at each step
- [ ] `daily_duas.json` contains 18–20 well-sourced entries with citations
- [ ] Daily Duas card visible in Home discovery carousel (5 cards total now)
- [ ] Daily Duas row visible in Explore tab below Life Moments
- [ ] DuasView and DuaDetailView render correctly across 5 themes and 3 languages
- [ ] Share action produces well-formatted text
- [ ] No regressions in Life Moments, Questions, Prophetic Stories, Ahl al-Bayt sections
- [ ] No new compiler warnings
- [ ] User reviews `daily_duas.json` content before committing

---

## Future follow-ups (out of scope for this plan)

- Audio recitation per dua (bundled MP3s)
- Bookmarking duas (full Supabase sync per `BOOKMARK_SYNC_ARCHITECTURE.md`)
- Expanded library (Mafatih, Sahifa Sajjadiyya, Ramadan-specific, Ziyarat)
- Daily push-notification dua of the day
- Search and category filtering (only justified once corpus grows past ~30 items)
- Localizing all `ExploreItem.title` values consistently (cross-feature work)
