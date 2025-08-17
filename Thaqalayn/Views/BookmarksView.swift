//
//  BookmarksView.swift
//  Thaqalayn
//
//  Modern bookmarks management with glassmorphism design
//

import SwiftUI


struct BookmarksView: View {
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedBookmark: Bookmark?
    @State private var showingBookmarkDetail = false
    @State private var searchText = ""
    @State private var selectedSortOrder: BookmarkSortOrder = .dateDescending
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground,
                    themeManager.tertiaryBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ModernBookmarksHeader(
                    bookmarkCount: filteredBookmarks.count,
                    onSortChange: { selectedSortOrder = $0 }
                )
                
                // Content
                if bookmarkManager.isLoading {
                    BookmarksLoadingView()
                } else if filteredBookmarks.isEmpty {
                    EmptyBookmarksView()
                } else {
                    BookmarksListView(
                        bookmarks: filteredBookmarks,
                        dataManager: dataManager
                    )
                }
                
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(themeManager.colorScheme)
        .searchable(text: $searchText, prompt: "Search bookmarks...")
        .sheet(isPresented: $showingBookmarkDetail) {
            if let bookmark = selectedBookmark {
                BookmarkDetailView(bookmark: bookmark)
            }
        }
    }
    
    private var filteredBookmarks: [Bookmark] {
        let sorted = bookmarkManager.getSortedBookmarks()
        
        if searchText.isEmpty {
            return sorted
        }
        
        return sorted.filter { bookmark in
            bookmark.surahName.localizedCaseInsensitiveContains(searchText) ||
            bookmark.verseTranslation.localizedCaseInsensitiveContains(searchText) ||
            bookmark.notes?.localizedCaseInsensitiveContains(searchText) == true ||
            bookmark.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct ModernBookmarksHeader: View {
    let bookmarkCount: Int
    let onSortChange: (BookmarkSortOrder) -> Void
    @State private var showingSortOptions = false
    @State private var showingClearAllConfirmation = false
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and sort button
            HStack {
                VStack(spacing: 4) {
                    if bookmarkCount > 0 {
                        Text("\(bookmarkCount) saved")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
                
                Spacer()
                
                Button(action: { showingSortOptions = true }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .confirmationDialog("Bookmark Options", isPresented: $showingSortOptions) {
            Section("Sort Options") {
                ForEach(BookmarkSortOrder.allCases, id: \.self) { sortOrder in
                    Button(sortOrder.title) {
                        onSortChange(sortOrder)
                    }
                }
            }
            
            if bookmarkCount > 0 {
                Section {
                    Button("Clear All Bookmarks", role: .destructive) {
                        showingClearAllConfirmation = true
                    }
                }
            }
        }
        .alert("Clear All Bookmarks?", isPresented: $showingClearAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                bookmarkManager.bookmarks.forEach { bookmark in
                    bookmarkManager.removeBookmark(id: bookmark.id)
                }
            }
        } message: {
            Text("This will permanently delete all \(bookmarkCount) bookmarks. This action cannot be undone.")
        }
    }
}

struct BookmarksListView: View {
    let bookmarks: [Bookmark]
    let dataManager: DataManager
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var bookmarkToDelete: Bookmark?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(bookmarks) { bookmark in
                    if let surahWithTafsir = createSurahWithTafsir(for: bookmark) {
                        NavigationLink(destination: SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: bookmark.verseNumber)) {
                            BookmarkCardContent(
                                bookmark: bookmark,
                                onDelete: { 
                                    bookmarkToDelete = bookmark
                                    showingDeleteConfirmation = true
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        BookmarkCard(
                            bookmark: bookmark,
                            onDelete: { 
                                bookmarkToDelete = bookmark
                                showingDeleteConfirmation = true
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .alert("Delete Bookmark?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let bookmark = bookmarkToDelete {
                    bookmarkManager.removeBookmark(id: bookmark.id)
                    bookmarkToDelete = nil
                }
            }
        } message: {
            if let bookmark = bookmarkToDelete {
                Text("Are you sure you want to delete the bookmark for \(bookmark.surahName) verse \(bookmark.verseNumber)?")
            }
        }
    }
    
    private func createSurahWithTafsir(for bookmark: Bookmark) -> SurahWithTafsir? {
        // First try to find in available surahs (with tafsir)
        if let surahWithTafsir = dataManager.availableSurahs.first(where: { $0.surah.number == bookmark.surahNumber }) {
            return surahWithTafsir
        }
        
        // Fallback to create from quran data (without tafsir)
        guard let quranData = dataManager.quranData,
              let surah = quranData.surahs.first(where: { $0.number == bookmark.surahNumber }),
              let surahVerses = quranData.verses[String(bookmark.surahNumber)] else {
            return nil
        }
        
        var verses: [VerseWithTafsir] = []
        for i in 1...surah.versesCount {
            let verseKey = String(i)
            if let verse = surahVerses[verseKey] {
                let verseWithTafsir = VerseWithTafsir(
                    number: i,
                    verse: verse,
                    tafsir: nil
                )
                verses.append(verseWithTafsir)
            }
        }
        
        return SurahWithTafsir(surah: surah, verses: verses)
    }
}

struct BookmarkCardContent: View {
    let bookmark: Bookmark
    let onDelete: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var isPressed = false
    @State private var showingDeleteButton = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with surah info and delete button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.surahName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Verse \(bookmark.verseNumber)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if showingDeleteButton {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.pink)
                    }
                }
            }
            
            // Verse translation preview
            Text(bookmark.verseTranslation)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Tags if any
            if !bookmark.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(bookmark.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.accentGradient)
                                )
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            // Date
            HStack {
                Spacer()
                Text(bookmark.createdAt, style: .date)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showingDeleteButton)
        .onLongPressGesture(minimumDuration: 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingDeleteButton.toggle()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

struct BookmarkCard: View {
    let bookmark: Bookmark
    let onDelete: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var isPressed = false
    @State private var showingDeleteButton = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with surah info and delete button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.surahName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Verse \(bookmark.verseNumber)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if showingDeleteButton {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.pink)
                    }
                }
            }
            
            // Verse translation preview
            Text(bookmark.verseTranslation)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Tags if any
            if !bookmark.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(bookmark.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.accentGradient)
                                )
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            // Date
            HStack {
                Spacer()
                Text(bookmark.createdAt, style: .date)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showingDeleteButton)
        .onLongPressGesture(minimumDuration: 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingDeleteButton.toggle()
            }
        }
        .onTapGesture {
            if showingDeleteButton {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showingDeleteButton = false
                }
            }
            // This is the fallback case - no navigation here
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

struct EmptyBookmarksView: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "heart")
                .font(.system(size: 60, weight: .thin))
                .foregroundColor(themeManager.secondaryText)
            
            VStack(spacing: 8) {
                Text("No Bookmarks Yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Text("Tap the heart icon on any verse to save it for later reading")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}


struct BookmarksLoadingView: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.primaryText))
                .scaleEffect(1.2)
            
            Text("Loading bookmarks...")
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BookmarkDetailView: View {
    let bookmark: Bookmark
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Surah and verse info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(bookmark.surahName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeManager.primaryText)
                            
                            Text("Verse \(bookmark.verseNumber)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        }
                        
                        // Arabic text
                        Text(bookmark.verseText)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .lineSpacing(6)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.glassEffect)
                            )
                        
                        // Translation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Translation")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeManager.secondaryText)
                            
                            Text(bookmark.verseTranslation)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.glassEffect)
                        )
                        
                        // Notes if any
                        if let notes = bookmark.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeManager.secondaryText)
                                
                                Text(notes)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.primaryText)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.glassEffect)
                            )
                        }
                        
                        // Tags if any
                        if !bookmark.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeManager.secondaryText)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                    ForEach(bookmark.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(themeManager.primaryText)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(themeManager.accentGradient)
                                            )
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.primaryText)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

#Preview {
    BookmarksView()
}