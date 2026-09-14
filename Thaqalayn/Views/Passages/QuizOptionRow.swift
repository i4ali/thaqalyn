// Thaqalayn/Views/Passages/QuizOptionRow.swift
import SwiftUI

/// One answer option, for every framing. `state` drives fill, border and the
/// marker on the left: an empty ring before answering, a green seal on the
/// right answer, a red ring with a cross on a wrong pick, dimmed for the rest.
struct QuizOptionRow: View {
    enum State { case idle, correct, wrong, dimmed }

    let text: String
    let state: State
    let centered: Bool
    let onTap: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    init(text: String, state: State, centered: Bool = false, onTap: @escaping () -> Void) {
        self.text = text
        self.state = state
        self.centered = centered
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if centered { Spacer(minLength: 0) }
                marker
                Text(text)
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(centered ? .center : .leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(border, lineWidth: 1))
            .opacity(state == .dimmed ? 0.45 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle.gentle)
        .disabled(state != .idle)
        .accessibilityLabel(accessibilityText)
    }

    private var fill: Color {
        switch state {
        case .correct: return themeManager.semanticGreen.opacity(0.16)
        case .wrong: return themeManager.semanticRed.opacity(0.14)
        default: return themeManager.glassSurface
        }
    }

    private var border: Color {
        switch state {
        case .correct: return themeManager.semanticGreen.opacity(0.55)
        case .wrong: return themeManager.semanticRed.opacity(0.55)
        default: return themeManager.strokeColor
        }
    }

    @ViewBuilder private var marker: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.semanticGreen)
        case .wrong:
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(themeManager.semanticRed)
                .frame(width: 22, height: 22)
                .overlay(Circle().stroke(themeManager.semanticRed, lineWidth: 1.5))
        default:
            Circle().stroke(themeManager.strokeColor, lineWidth: 1.5).frame(width: 22, height: 22)
        }
    }

    private var accessibilityText: String {
        switch state {
        case .correct: return "\(text), correct answer"
        case .wrong: return "\(text), your answer, wrong"
        default: return text
        }
    }
}
