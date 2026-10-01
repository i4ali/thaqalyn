//
//  SurahDetailView.swift
//  Thaqalayn
//
//  Entry point every navigation site uses to open a surah. Since the passage
//  reader (2026-09) it is a thin wrapper over SurahPassagesView: a surah is a
//  list of its passages; targetVerse opens the reader for the passage that
//  holds the verse, and targetPassageIndex opens that passage's hub.
//

import SwiftUI

struct SurahDetailView: View {
    let surahWithTafsir: SurahWithTafsir
    let targetVerse: Int?
    let targetConceptId: String?
    let targetPassageIndex: Int?

    init(surahWithTafsir: SurahWithTafsir, targetVerse: Int? = nil, targetConceptId: String? = nil, targetPassageIndex: Int? = nil) {
        self.surahWithTafsir = surahWithTafsir
        self.targetVerse = targetVerse
        self.targetConceptId = targetConceptId
        self.targetPassageIndex = targetPassageIndex
    }

    var body: some View {
        SurahPassagesView(
            surahWithTafsir: surahWithTafsir,
            targetVerse: targetVerse,
            targetConceptId: targetConceptId,
            targetPassageIndex: targetPassageIndex
        )
    }
}
