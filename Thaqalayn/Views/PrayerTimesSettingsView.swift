//
//  PrayerTimesSettingsView.swift
//  Thaqalayn
//
//  Settings and configuration for prayer times
//

import SwiftUI

struct PrayerTimesSettingsView: View {
    @StateObject private var prayerTimesManager = PrayerTimesManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                themeManager.primaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Location Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Location")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.primaryText)
                                .padding(.horizontal, 4)

                            VStack(spacing: 12) {
                                // Current location
                                HStack(spacing: 16) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.blue)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Current Location")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(themeManager.primaryText)

                                        Text(locationManager.locationDisplayString())
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(themeManager.secondaryText)
                                    }

                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.glassEffect)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeManager.strokeColor, lineWidth: 1)
                                        )
                                )

                                // Update location button
                                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                                    Button(action: {
                                        locationManager.requestLocation()
                                    }) {
                                        HStack {
                                            if locationManager.isLoading {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            } else {
                                                Image(systemName: "arrow.clockwise")
                                            }
                                            Text(locationManager.isLoading ? "Updating..." : "Update Location")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.blue)
                                        )
                                    }
                                    .disabled(locationManager.isLoading)
                                } else {
                                    Button(action: {
                                        if locationManager.authorizationStatus == .notDetermined {
                                            locationManager.requestPermission()
                                        } else {
                                            locationManager.openSettings()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "location.fill")
                                            Text(locationManager.authorizationStatus == .notDetermined ? "Enable Location" : "Open Settings")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.orange)
                                        )
                                    }
                                }
                            }
                        }

                        // Calculation Method Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Calculation Method")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.primaryText)
                                .padding(.horizontal, 4)

                            VStack(spacing: 0) {
                                ForEach(CalculationMethod.allCases, id: \.self) { method in
                                    Button(action: {
                                        prayerTimesManager.preferences.selectedAcalculationMethod = method
                                    }) {
                                        HStack(spacing: 16) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(method.displayName)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(themeManager.primaryText)

                                                Text(method.description)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(themeManager.secondaryText)
                                            }

                                            Spacer()

                                            if prayerTimesManager.preferences.selectedAcalculationMethod == method {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.green)
                                            } else {
                                                Image(systemName: "circle")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(themeManager.tertiaryText)
                                            }
                                        }
                                        .padding(16)
                                        .background(
                                            Rectangle()
                                                .fill(prayerTimesManager.preferences.selectedAcalculationMethod == method ?
                                                      themeManager.accentColor.opacity(0.1) : Color.clear)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if method != CalculationMethod.allCases.last {
                                        Divider()
                                            .background(themeManager.strokeColor)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.strokeColor, lineWidth: 1)
                                    )
                            )
                        }

                        // Notifications Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notifications")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.primaryText)
                                .padding(.horizontal, 4)

                            VStack(spacing: 12) {
                                // Enable notifications toggle
                                HStack(spacing: 16) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.blue)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Prayer Notifications")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(themeManager.primaryText)

                                        Text(prayerTimesManager.preferences.notificationsEnabled ? "Enabled" : "Disabled")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(themeManager.secondaryText)
                                    }

                                    Spacer()

                                    Toggle("", isOn: Binding(
                                        get: { prayerTimesManager.preferences.notificationsEnabled },
                                        set: { prayerTimesManager.preferences.notificationsEnabled = $0 }
                                    ))
                                    .labelsHidden()
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.glassEffect)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeManager.strokeColor, lineWidth: 1)
                                        )
                                )

                                // Athan for individual prayers
                                if prayerTimesManager.preferences.notificationsEnabled {
                                    VStack(spacing: 1) {
                                        ForEach(PrayerTime.allCases.filter { $0.isPrayer }, id: \.self) { prayer in
                                            HStack(spacing: 16) {
                                                Image(systemName: prayer.icon)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(themeManager.accentColor)
                                                    .frame(width: 24)

                                                Text(prayer.rawValue)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(themeManager.primaryText)

                                                Spacer()

                                                Toggle("", isOn: Binding(
                                                    get: { prayerTimesManager.preferences.athanEnabled[prayer] ?? true },
                                                    set: {
                                                        var newAthanEnabled = prayerTimesManager.preferences.athanEnabled
                                                        newAthanEnabled[prayer] = $0
                                                        prayerTimesManager.preferences.athanEnabled = newAthanEnabled
                                                    }
                                                ))
                                                .labelsHidden()
                                            }
                                            .padding(16)
                                            .background(
                                                Rectangle()
                                                    .fill(Color.clear)
                                            )

                                            if prayer != PrayerTime.allCases.filter({ $0.isPrayer }).last {
                                                Divider()
                                                    .background(themeManager.strokeColor)
                                            }
                                        }
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.glassEffect)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }

                        // Athan Audio Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Athan Audio")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.primaryText)
                                .padding(.horizontal, 4)

                            VStack(spacing: 0) {
                                ForEach(AthanAudio.allCases, id: \.self) { audio in
                                    Button(action: {
                                        prayerTimesManager.athanPreferences.selectedAudio = audio
                                    }) {
                                        HStack(spacing: 16) {
                                            Text(audio.displayName)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(themeManager.primaryText)

                                            Spacer()

                                            if prayerTimesManager.athanPreferences.selectedAudio == audio {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.green)
                                            } else {
                                                Image(systemName: "circle")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(themeManager.tertiaryText)
                                            }
                                        }
                                        .padding(16)
                                        .background(
                                            Rectangle()
                                                .fill(prayerTimesManager.athanPreferences.selectedAudio == audio ?
                                                      themeManager.accentColor.opacity(0.1) : Color.clear)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if audio != AthanAudio.allCases.last {
                                        Divider()
                                            .background(themeManager.strokeColor)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.strokeColor, lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Prayer Times Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

#Preview {
    PrayerTimesSettingsView()
}
