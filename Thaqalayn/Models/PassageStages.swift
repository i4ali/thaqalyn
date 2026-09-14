//
//  PassageStages.swift
//  Thaqalayn
//
//  The three stages of a passage - Read, Understand, Test yourself - and where
//  a reader stands in them. Understand exists only where the commentary has
//  shipped and Test only where the quiz has, so a passage with verses alone
//  is complete once it is read. The passage hub, the list ring and the
//  hub's bottom bar all read from this one value.
//

import Foundation

struct PassageStages: Equatable {
    enum Stage: Equatable, CaseIterable {
        case read, understand, test
    }

    let isRead: Bool
    let isUnderstood: Bool
    /// Best quiz score out of `quizTotal`, once the quiz has been taken.
    let bestScore: Int?
    let quizTotal: Int
    let hasCommentary: Bool
    let hasQuiz: Bool

    init(isRead: Bool,
         isUnderstood: Bool,
         bestScore: Int? = nil,
         quizTotal: Int = 5,
         hasCommentary: Bool,
         hasQuiz: Bool) {
        self.isRead = isRead
        self.isUnderstood = isUnderstood
        self.bestScore = bestScore
        self.quizTotal = quizTotal
        self.hasCommentary = hasCommentary
        self.hasQuiz = hasQuiz
    }

    /// The stages this passage offers, in order.
    var available: [Stage] {
        var out: [Stage] = [.read]
        if hasCommentary { out.append(.understand) }
        if hasQuiz { out.append(.test) }
        return out
    }

    func isDone(_ stage: Stage) -> Bool {
        switch stage {
        case .read: return isRead
        case .understand: return isUnderstood
        case .test: return bestScore != nil
        }
    }

    var total: Int { available.count }
    var doneCount: Int { available.filter(isDone).count }
    var isComplete: Bool { doneCount == total }

    /// The first stage still to do, in order; nil once the passage is complete.
    var next: Stage? { available.first { !isDone($0) } }
}
