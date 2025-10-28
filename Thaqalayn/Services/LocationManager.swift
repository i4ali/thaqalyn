//
//  LocationManager.swift
//  Thaqalayn
//
//  Service for managing location services for prayer times
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: LocationData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let userDefaultsKey = "savedLocationData"

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // We don't need high accuracy
        authorizationStatus = locationManager.authorizationStatus

        // Load saved location
        loadSavedLocation()
    }

    // MARK: - Permission Management

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Location Retrieval

    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorMessage = "Location permission not granted"
            return
        }

        isLoading = true
        errorMessage = nil
        locationManager.requestLocation()
    }

    // MARK: - Manual Location

    func setManualLocation(latitude: Double, longitude: Double, city: String? = nil, country: String? = nil) {
        let timezone = TimeZone.current.identifier
        let location = LocationData(
            latitude: latitude,
            longitude: longitude,
            city: city,
            country: country,
            timezone: timezone,
            lastUpdated: Date()
        )

        currentLocation = location
        saveLocation(location)
    }

    // MARK: - Persistence

    private func saveLocation(_ location: LocationData) {
        if let encoded = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedLocation() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(LocationData.self, from: data) {
            currentLocation = decoded
        }
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ LocationManager: Reverse geocoding error - \(error.localizedDescription)")
                // Save location without city/country info
                let locationData = LocationData(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    city: nil,
                    country: nil,
                    timezone: TimeZone.current.identifier,
                    lastUpdated: Date()
                )

                DispatchQueue.main.async {
                    self.currentLocation = locationData
                    self.saveLocation(locationData)
                    self.isLoading = false
                }
                return
            }

            if let placemark = placemarks?.first {
                let locationData = LocationData(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    city: placemark.locality,
                    country: placemark.country,
                    timezone: TimeZone.current.identifier,
                    lastUpdated: Date()
                )

                DispatchQueue.main.async {
                    self.currentLocation = locationData
                    self.saveLocation(locationData)
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Location Display

    func locationDisplayString() -> String {
        guard let location = currentLocation else {
            return "No location set"
        }

        if let city = location.city, let country = location.country {
            return "\(city), \(country)"
        } else if let city = location.city {
            return city
        } else if let country = location.country {
            return country
        } else {
            return String(format: "%.2f°, %.2f°", location.latitude, location.longitude)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Reverse geocode to get city/country
        reverseGeocode(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ LocationManager: Location request failed - \(error.localizedDescription)")

        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}
