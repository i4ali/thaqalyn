//
//  WidgetExplainerView.swift
//  Thaqalayn
//
//  Explains the Daily Reflection home-screen widget and captures the one-time
//  location fix that enables its prayer beats. Reached from Settings and from
//  the What's New card. Copy is EN/UR/AR via LocalizedText; widget explainer
//  text is UI chrome, so it does not scale with the reading text-size control.
//

import SwiftUI

struct WidgetExplainerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var locationService = PrayerLocationService()

    // MARK: - Copy (en authored; plain spelling, no em dashes)

    private enum Copy {
        static let title = LocalizedText(
            en: "The Daily Reflection Widget",
            ur: "ڈیلی ریفلیکشن ویجیٹ",
            ar: "ودجة التأمل اليومي")
        static let intro = LocalizedText(
            en: "One verse anchors your day. It unfolds on your Home Screen as the day moves: the verse in the morning, a hidden gem after midday, a doorway into a journey or deep dive through the evening, and a quiet close at night.",
            ur: "ایک آیت آپ کے دن کا مرکز بنتی ہے۔ دن گزرنے کے ساتھ یہ آپ کی ہوم اسکرین پر کھلتی جاتی ہے: صبح آیت، دوپہر کے بعد ایک موتی، شام بھر کسی سفر یا گہرے غوطے کا دروازہ، اور رات میں پرسکون اختتام۔",
            ar: "آية واحدة يرسو عليها نهارك. تتكشف على شاشتك الرئيسية مع مرور اليوم: الآية في الصباح، وجوهرة بعد الظهر، وباب إلى رحلة أو غوص عميق طوال المساء، ثم ختام هادئ في الليل.")
        static let prayers = LocalizedText(
            en: "Add your location once and the widget also marks the five daily prayers on Shia (Ja'fari) timings, each with a short line about salah.",
            ur: "ایک بار اپنا مقام شامل کریں تو ویجیٹ شیعہ (جعفری) اوقات کے مطابق پانچوں نمازوں کی نشاندہی بھی کرے گا، ہر ایک کے ساتھ نماز کے بارے میں ایک مختصر جملہ۔",
            ar: "أضف موقعك مرة واحدة لتعرض الودجة أيضا أوقات الصلوات الخمس وفق التوقيت الجعفري، مع سطر قصير عن الصلاة.")
        static let addTitle = LocalizedText(
            en: "Add it to your Home Screen",
            ur: "ہوم اسکرین پر شامل کریں",
            ar: "أضفها إلى الشاشة الرئيسية")
        static let addSteps = LocalizedText(
            en: "Touch and hold your Home Screen, tap the + button, search for Thaqalayn, and choose a size.",
            ur: "ہوم اسکرین کو دیر تک دبائیں، + بٹن پر ٹیپ کریں، Thaqalayn تلاش کریں، اور سائز منتخب کریں۔",
            ar: "اضغط مطولا على الشاشة الرئيسية، ثم اضغط زر +، وابحث عن Thaqalayn، واختر الحجم.")
        static let enableButton = LocalizedText(
            en: "Enable Prayer Times",
            ur: "نماز کے اوقات فعال کریں",
            ar: "تفعيل أوقات الصلاة")
        static let locating = LocalizedText(
            en: "Finding your location...",
            ur: "آپ کا مقام معلوم کیا جا رہا ہے...",
            ar: "جار تحديد موقعك...")
        static let saved = LocalizedText(
            en: "Prayer times enabled",
            ur: "نماز کے اوقات فعال ہو گئے",
            ar: "تم تفعيل أوقات الصلاة")
        static let denied = LocalizedText(
            en: "Location permission was denied. Allow it in iOS Settings to show prayer times.",
            ur: "مقام کی اجازت نہیں ملی۔ نماز کے اوقات کے لیے iOS سیٹنگز میں اجازت دیں۔",
            ar: "لم يسمح بالوصول إلى الموقع. فعله من إعدادات iOS لعرض أوقات الصلاة.")
        static let failed = LocalizedText(
            en: "Could not get a location fix. Try again.",
            ur: "مقام حاصل نہیں ہو سکا۔ دوبارہ کوشش کریں۔",
            ar: "تعذر تحديد الموقع. حاول مرة أخرى.")
        static let privacy = LocalizedText(
            en: "Your location is saved on your device only and is used just to compute prayer times.",
            ur: "آپ کا مقام صرف آپ کے آلے پر محفوظ رہتا ہے اور صرف نماز کے اوقات کے حساب کے لیے استعمال ہوتا ہے۔",
            ar: "يبقى موقعك محفوظا على جهازك فقط ويستخدم لحساب أوقات الصلاة لا غير.")
    }


    var body: some View {
        ZStack {
            themeManager.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(Copy.intro.text)
                            .font(bodyFont)
                            .foregroundColor(themeManager.primaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(Copy.prayers.text)
                            .font(bodyFont)
                            .foregroundColor(themeManager.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        addCard

                        enableCard

                        Text(Copy.privacy.text)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    // MARK: - Pieces

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text(Copy.title.text)
                .font(titleFont)
                .foregroundColor(themeManager.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            Rectangle()
                .fill(Color.clear)
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }

    private var addCard: some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.square.on.square")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                    Text(Copy.addTitle.text)
                        .font(headingFont)
                        .foregroundColor(themeManager.primaryText)
                }
                Text(Copy.addSteps.text)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }

    private var enableCard: some View {
        card {
            VStack(spacing: 12) {
                Button(action: { locationService.captureOnce() }) {
                    HStack(spacing: 8) {
                        Image(systemName: locationService.status == .saved
                              ? "checkmark.circle.fill" : "location.fill")
                            .font(.system(size: 15, weight: .semibold))
                        Text(locationService.status == .saved
                             ? Copy.saved.text
                             : Copy.enableButton.text)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(themeManager.accentColor.opacity(
                                locationService.status == .saved ? 0.55 : 1))
                    )
                }
                .disabled(locationService.status == .saved || locationService.status == .locating)

                if let note = statusNote {
                    Text(note)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(locationService.status == .denied
                                         ? Color(red: 0.86, green: 0.49, blue: 0.45)
                                         : themeManager.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
        }
    }

    private var statusNote: String? {
        switch locationService.status {
        case .idle: return nil
        case .locating: return Copy.locating.text
        case .saved: return Copy.saved.text
        case .denied: return Copy.denied.text
        case .failed: return Copy.failed.text
        }
    }

    // MARK: - Theme helpers

    private var titleFont: Font {
        themeManager.isMidnightEmerald ? EmType.serif(24, .semiBold) : .system(size: 20, weight: .bold)
    }
    private var headingFont: Font {
        themeManager.isMidnightEmerald ? EmType.serif(19, .semiBold) : .system(size: 16, weight: .semibold)
    }
    private var bodyFont: Font {
        .system(size: 15, weight: .regular)
    }

    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if themeManager.isMidnightEmerald {
            EmCard(cornerRadius: 16) { content() }
        } else {
            content()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
        }
    }
}

#Preview {
    WidgetExplainerView()
}
