//
//  PrayerTimesView.swift
//  Thaqalayn
//
//  Main prayer times display widget with countdown
//

import SwiftUI

struct PrayerTimesView: View {
    @StateObject private var prayerTimesManager = PrayerTimesManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var currentTime = Date()
    @State private var showingSettings = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prayer Times")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    if let location = locationManager.currentLocation {
                        Text(locationManager.locationDisplayString())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    } else {
                        Text("Location not set")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    Circle()
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            if locationManager.currentLocation == nil {
                // No location set
                VStack(spacing: 16) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)

                    Text("Location Required")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)

                    Text("Enable location services to calculate accurate prayer times")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    if locationManager.authorizationStatus == .notDetermined {
                        Button(action: {
                            locationManager.requestPermission()
                        }) {
                            Text("Enable Location")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                        }
                    } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                        Button(action: {
                            locationManager.openSettings()
                        }) {
                            Text("Open Settings")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange)
                                )
                        }
                    } else {
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            HStack(spacing: 8) {
                                if locationManager.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "location.fill")
                                }
                                Text(locationManager.isLoading ? "Getting Location..." : "Get My Location")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)

            } else if let prayerTimes = prayerTimesManager.prayerTimes {
                // Prayer times available
                VStack(spacing: 0) {
                    // Next prayer countdown
                    if let nextPrayer = prayerTimes.nextPrayer(at: currentTime),
                       let nextPrayerTime = prayerTimes.times[nextPrayer],
                       let timeRemaining = prayerTimes.timeUntilNextPrayer(at: currentTime) {
                        NextPrayerCard(
                            prayer: nextPrayer,
                            time: nextPrayerTime,
                            timeRemaining: timeRemaining
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }

                    // All prayer times list
                    VStack(spacing: 1) {
                        ForEach(PrayerTime.allCases, id: \.self) { prayer in
                            if let time = prayerTimes.times[prayer] {
                                PrayerTimeRow(
                                    prayer: prayer,
                                    time: time,
                                    isNext: prayerTimes.nextPrayer(at: currentTime) == prayer,
                                    isCurrent: prayerTimes.currentPrayer(at: currentTime) == prayer
                                )
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.glassEffect)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                }

            } else {
                // Calculating
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color(red: 0.39, green: 0.4, blue: 0.95))

                    Text("Calculating Prayer Times...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }

            Spacer()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onAppear {
            // Calculate prayer times when view appears
            if locationManager.currentLocation != nil && prayerTimesManager.prayerTimes == nil {
                prayerTimesManager.calculatePrayerTimes()
            }
        }
        .onChange(of: locationManager.currentLocation) { _ in
            // Recalculate when location changes
            prayerTimesManager.calculatePrayerTimes()
        }
        .sheet(isPresented: $showingSettings) {
            PrayerTimesSettingsView()
        }
    }
}

// MARK: - Next Prayer Card

struct NextPrayerCard: View {
    let prayer: PrayerTime
    let time: Date
    let timeRemaining: TimeInterval
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: prayer.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Next Prayer")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)

                    Text(prayer.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(time))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text(formatTimeRemaining(timeRemaining))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            themeManager.accentColor.opacity(0.2),
                            themeManager.accentColor.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else {
            return "in \(minutes)m"
        }
    }
}

// MARK: - Prayer Time Row

struct PrayerTimeRow: View {
    let prayer: PrayerTime
    let time: Date
    let isNext: Bool
    let isCurrent: Bool
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isNext ? themeManager.accentColor.opacity(0.2) : themeManager.secondaryBackground.opacity(0.5))
                    .frame(width: 40, height: 40)

                Image(systemName: prayer.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isNext ? themeManager.accentColor : themeManager.tertiaryText)
            }

            // Prayer name
            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.rawValue)
                    .font(.system(size: 16, weight: isNext ? .bold : .semibold))
                    .foregroundColor(isNext ? themeManager.accentColor : themeManager.primaryText)

                Text(prayer.arabicName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            // Time
            Text(formatTime(time))
                .font(.system(size: 16, weight: isNext ? .bold : .semibold))
                .foregroundColor(isNext ? themeManager.accentColor : themeManager.primaryText)

            // Status indicator
            if isCurrent {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            } else if isNext {
                Image(systemName: "bell.fill")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.accentColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(isNext ? themeManager.accentColor.opacity(0.05) : Color.clear)
        )
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.1, green: 0.1, blue: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        PrayerTimesView()
    }
}
