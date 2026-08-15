//
//  PrayerLocationService.swift
//  Thaqalayn
//
//  One-shot location capture for the widget's prayer beats. Requests
//  when-in-use authorization, takes a single fix, writes it to the App Group
//  (WidgetLocationStore), and reloads the widget timelines. No continuous
//  updates, no background modes - the widget computes times for any date
//  from the cached coordinates.
//

import Foundation
import CoreLocation
import WidgetKit

final class PrayerLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    enum Status: Equatable {
        case idle       // nothing captured yet
        case locating   // waiting for authorization or a fix
        case saved      // location cached, widgets reloaded
        case denied     // user declined location permission
        case failed     // fix failed; can retry
    }

    @Published private(set) var status: Status = .idle

    private let manager = CLLocationManager()
    private let store = WidgetLocationStore()

    override init() {
        super.init()
        manager.delegate = self
        // City-level accuracy is plenty for prayer times and resolves fast.
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        if store.load() != nil { status = .saved }
    }

    func captureOnce() {
        switch manager.authorizationStatus {
        case .notDetermined:
            status = .locating
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            status = .denied
        default:
            status = .locating
            manager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            guard self.status == .locating else { return }
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                self.status = .denied
            default:
                break   // still .notDetermined; keep waiting
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let fix = locations.first else { return }
        DispatchQueue.main.async {
            self.store.save(latitude: fix.coordinate.latitude,
                            longitude: fix.coordinate.longitude,
                            timeZoneId: TimeZone.current.identifier)
            WidgetCenter.shared.reloadAllTimelines()
            self.status = .saved
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            if self.status == .locating { self.status = .failed }
        }
    }
}
