//
//  CacheManager.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import Foundation
import CoreData

@MainActor
class CacheManager: ObservableObject {
    static let shared = CacheManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TafsirCache")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    // Helper methods for sources array encoding/decoding
    private func encodeSources(_ sources: [String]) -> String {
        guard let data = try? JSONEncoder().encode(sources) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }
    
    private func parseSourcesString(_ sourcesString: String?) -> [String] {
        guard let sourcesString = sourcesString,
              let data = sourcesString.data(using: .utf8),
              let sources = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return sources
    }
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Tafsir Cache Methods
    
    func getCachedTafsir(surah: Int, ayah: Int, layer: Int) -> TafsirContent? {
        let request: NSFetchRequest<TafsirCache> = TafsirCache.fetchRequest()
        request.predicate = NSPredicate(
            format: "surah == %d AND ayah == %d AND layer == %d",
            surah, ayah, layer
        )
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            guard let cachedItem = results.first else { return nil }
            
            return TafsirContent(
                surah: Int(cachedItem.surah),
                ayah: Int(cachedItem.ayah),
                layer: Int(cachedItem.layer),
                content: cachedItem.content ?? "",
                sources: parseSourcesString(cachedItem.sources),
                generatedAt: cachedItem.generatedAt ?? Date(),
                confidenceScore: cachedItem.confidenceScore
            )
        } catch {
            print("Failed to fetch cached tafsir: \(error)")
            return nil
        }
    }
    
    func cacheTafsir(_ content: TafsirContent, arabicText: String? = nil, translation: String? = nil) {
        // Check if already cached
        if getCachedTafsir(surah: content.surah, ayah: content.ayah, layer: content.layer) != nil {
            return
        }
        
        let cachedItem = TafsirCache(context: context)
        cachedItem.surah = Int16(content.surah)
        cachedItem.ayah = Int16(content.ayah)
        cachedItem.layer = Int16(content.layer)
        cachedItem.content = content.content
        cachedItem.sources = encodeSources(content.sources)
        cachedItem.generatedAt = content.generatedAt
        cachedItem.confidenceScore = content.confidenceScore
        cachedItem.arabicText = arabicText
        cachedItem.translation = translation
        
        save()
    }
    
    func getAllCachedTafsir(for surah: Int, ayah: Int) -> [TafsirContent] {
        let request: NSFetchRequest<TafsirCache> = TafsirCache.fetchRequest()
        request.predicate = NSPredicate(format: "surah == %d AND ayah == %d", surah, ayah)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TafsirCache.layer, ascending: true)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { cachedItem in
                TafsirContent(
                    surah: Int(cachedItem.surah),
                    ayah: Int(cachedItem.ayah),
                    layer: Int(cachedItem.layer),
                    content: cachedItem.content ?? "",
                    sources: parseSourcesString(cachedItem.sources),
                    generatedAt: cachedItem.generatedAt ?? Date(),
                    confidenceScore: cachedItem.confidenceScore
                )
            }
        } catch {
            print("Failed to fetch all cached tafsir: \(error)")
            return []
        }
    }
    
    func clearOldCache(olderThan days: Int = 30) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let request: NSFetchRequest<TafsirCache> = TafsirCache.fetchRequest()
        request.predicate = NSPredicate(format: "generatedAt < %@", cutoffDate as NSDate)
        
        do {
            let oldItems = try context.fetch(request)
            for item in oldItems {
                context.delete(item)
            }
            save()
            print("Cleared \(oldItems.count) old cache items")
        } catch {
            print("Failed to clear old cache: \(error)")
        }
    }
    
    // MARK: - Bookmark Methods
    
    func getBookmarks() -> [LocalBookmark] {
        let request: NSFetchRequest<LocalBookmark> = LocalBookmark.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LocalBookmark.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch bookmarks: \(error)")
            return []
        }
    }
    
    func addBookmark(surah: Int, ayah: Int, note: String? = nil) {
        // Check if bookmark already exists
        let request: NSFetchRequest<LocalBookmark> = LocalBookmark.fetchRequest()
        request.predicate = NSPredicate(format: "surah == %d AND ayah == %d", surah, ayah)
        
        do {
            let existingBookmarks = try context.fetch(request)
            if !existingBookmarks.isEmpty {
                print("Bookmark already exists for \(surah):\(ayah)")
                return
            }
        } catch {
            print("Failed to check existing bookmarks: \(error)")
        }
        
        let bookmark = LocalBookmark(context: context)
        bookmark.id = UUID()
        bookmark.surah = Int16(surah)
        bookmark.ayah = Int16(ayah)
        bookmark.note = note
        bookmark.createdAt = Date()
        
        save()
    }
    
    func removeBookmark(surah: Int, ayah: Int) {
        let request: NSFetchRequest<LocalBookmark> = LocalBookmark.fetchRequest()
        request.predicate = NSPredicate(format: "surah == %d AND ayah == %d", surah, ayah)
        
        do {
            let bookmarks = try context.fetch(request)
            for bookmark in bookmarks {
                context.delete(bookmark)
            }
            save()
        } catch {
            print("Failed to remove bookmark: \(error)")
        }
    }
    
    func isBookmarked(surah: Int, ayah: Int) -> Bool {
        let request: NSFetchRequest<LocalBookmark> = LocalBookmark.fetchRequest()
        request.predicate = NSPredicate(format: "surah == %d AND ayah == %d", surah, ayah)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Failed to check bookmark status: \(error)")
            return false
        }
    }
    
    func updateBookmarkNote(surah: Int, ayah: Int, note: String) {
        let request: NSFetchRequest<LocalBookmark> = LocalBookmark.fetchRequest()
        request.predicate = NSPredicate(format: "surah == %d AND ayah == %d", surah, ayah)
        request.fetchLimit = 1
        
        do {
            let bookmarks = try context.fetch(request)
            if let bookmark = bookmarks.first {
                bookmark.note = note
                save()
            }
        } catch {
            print("Failed to update bookmark note: \(error)")
        }
    }
    
    // MARK: - Cache Statistics
    
    func getCacheStats() -> CacheStats {
        let tafsirRequest: NSFetchRequest<TafsirCache> = TafsirCache.fetchRequest()
        let bookmarkRequest: NSFetchRequest<LocalBookmark> = LocalBookmark.fetchRequest()
        
        do {
            let tafsirCount = try context.count(for: tafsirRequest)
            let bookmarkCount = try context.count(for: bookmarkRequest)
            
            // Calculate cache size (approximate)
            let results = try context.fetch(tafsirRequest)
            let totalSize = results.reduce(0) { total, item in
                total + (item.content?.count ?? 0)
            }
            
            return CacheStats(
                cachedTafsirCount: tafsirCount,
                bookmarkCount: bookmarkCount,
                approximateSizeBytes: totalSize
            )
        } catch {
            print("Failed to get cache stats: \(error)")
            return CacheStats(cachedTafsirCount: 0, bookmarkCount: 0, approximateSizeBytes: 0)
        }
    }
}

struct CacheStats {
    let cachedTafsirCount: Int
    let bookmarkCount: Int
    let approximateSizeBytes: Int
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(approximateSizeBytes), countStyle: .file)
    }
}