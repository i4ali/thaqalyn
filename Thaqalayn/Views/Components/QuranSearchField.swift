//
//  QuranSearchField.swift
//  Thaqalayn
//
//  The Quran-tab search box, shared by the Midnight Emerald and legacy layouts
//  (and Find in this Surah). The whole box focuses the field, a clear button
//  appears once there is text, and autocorrect/auto-capitalization stay off so
//  transliterated words ("sabr", "yasin") are searched as typed.
//

import SwiftUI

struct QuranSearchField: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    var placeholder: String = QuranTabStrings.searchPlaceholder
    var keyboard: UIKeyboardType = .default
    var onSubmit: () -> Void = {}

    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 10) {
            if themeManager.isMidnightEmerald {
                PhosphorIcon(name: "ph-magnifying-glass", size: 16)
                    .foregroundColor(themeManager.accentColor)
            } else {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.secondaryText)
            }

            TextField("", text: $text,
                      prompt: Text(placeholder).foregroundColor(themeManager.tertiaryText))
                .focused(isFocused)
                .font(.system(size: 15))
                .foregroundColor(themeManager.primaryText)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit {
                    isFocused.wrappedValue = false
                    onSubmit()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                    isFocused.wrappedValue = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.tertiaryText)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(QuranTabStrings.clearSearch)
            }
        }
        .padding(.leading, 14).padding(.trailing, text.isEmpty ? 14 : 8)
        .padding(.vertical, themeManager.isMidnightEmerald ? 13 : 15)
        // Taps on the icon or the padding focus the field too; the TextField and
        // the clear button handle their own taps on top of this layer.
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { isFocused.wrappedValue = true }
        )
        .background(boxBackground)
    }

    @ViewBuilder private var boxBackground: some View {
        if themeManager.isMidnightEmerald {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.glassSurface)
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isFocused.wrappedValue ? themeManager.accentColor.opacity(0.55) : themeManager.strokeColor,
                            lineWidth: 1))
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused.wrappedValue ? themeManager.accentColor.opacity(0.5) : themeManager.strokeColor,
                            lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        }
    }
}

/// Field plus the Cancel button shown while searching. Cancel clears the query
/// and drops focus, returning the tab to its browse layout.
struct QuranSearchBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let isSearching: Bool

    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 12) {
            QuranSearchField(text: $text, isFocused: isFocused)
            if isSearching {
                Button {
                    text = ""
                    isFocused.wrappedValue = false
                } label: {
                    Text(QuranTabStrings.cancel)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}
