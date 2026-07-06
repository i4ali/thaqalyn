//
//  WhatsNewManager.swift
//  Thaqalayn
//
//  Drives the Today-tab What's New spotlight. Tracks per-item seen state (opened OR
//  dismissed) in UserDefaults and publishes the current `spotlight`: the newest unseen
//  announcement, retired on open/dismiss or after a quiet long-stop. Device-local only -
//  seen-state is low-stakes and ephemeral, so it deliberately does not use the cloud
//  sync architecture.
//

import SwiftUI

@MainActor
final class WhatsNewManager: ObservableObject {
    static let shared = WhatsNewManager()

    /// The feature to spotlight right now, or nil when nothing is unseen.
    @Published private(set) var spotlight: WhatsNewItem?

    private let seenKey = "whatsNew.seenIds"
    private let surfacedKey = "whatsNew.firstSurfacedAt"
    private let seededKey = "whatsNew.didSeedFreshInstall"

    /// A never-touched card auto-retires after this long (the quiet long-stop).
    private let longStop: TimeInterval = 21 * 24 * 60 * 60

    private var seenIds: Set<String>
    private var firstSurfacedAt: [String: Date]

    private init() {
        let d = UserDefaults.standard
        seenIds = Set(d.stringArray(forKey: seenKey) ?? [])
        firstSurfacedAt = (d.dictionary(forKey: surfacedKey) as? [String: Date]) ?? [:]
        refresh()
    }

    /// Recompute the spotlight and stamp its first-surfaced time. Call on Today appear.
    func refresh() {
        let now = Date()
        let candidate = WhatsNewCatalog.all
            .sorted { $0.releaseDate > $1.releaseDate }
            .first { item in
                if seenIds.contains(item.id) { return false }
                if let t = firstSurfacedAt[item.id], now.timeIntervalSince(t) > longStop { return false }
                return true
            }
        if let item = candidate, firstSurfacedAt[item.id] == nil {
            firstSurfacedAt[item.id] = now
            persist()
        }
        spotlight = candidate
    }

    /// User opened the feature - retire it and advance the queue.
    func markOpened(_ id: String) { retire(id) }
    /// User dismissed the card - retire it and advance the queue.
    func dismiss(_ id: String) { retire(id) }

    private func retire(_ id: String) {
        seenIds.insert(id)
        persist()
        refresh()
    }

    /// Fresh-install suppression: a brand-new user is discovering the whole app, so mark
    /// every currently-shipped announcement as already seen. Only features added in LATER
    /// updates will surface for them. Idempotent. Call from the app's first-launch path.
    func seedAllAsSeenForFreshInstall() {
        let d = UserDefaults.standard
        guard !d.bool(forKey: seededKey) else { return }
        seenIds.formUnion(WhatsNewCatalog.all.map { $0.id })
        d.set(true, forKey: seededKey)
        persist()
        refresh()
    }

    private func persist() {
        let d = UserDefaults.standard
        d.set(Array(seenIds), forKey: seenKey)
        d.set(firstSurfacedAt, forKey: surfacedKey)
    }

    #if DEBUG
    /// Wipe all What's New state so the spotlight reappears. Driven by -wnReset (Task 8).
    func debugReset() {
        let d = UserDefaults.standard
        [seenKey, surfacedKey, seededKey].forEach { d.removeObject(forKey: $0) }
        seenIds = []; firstSurfacedAt = [:]
        refresh()
    }
    #endif
}
