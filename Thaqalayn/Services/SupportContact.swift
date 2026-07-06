//
//  SupportContact.swift
//  Thaqalayn
//
//  Single source of truth for contacting the developer. Builds a pre-filled
//  mailto: email and opens it in the user's default mail app, mirroring the
//  way RatingManager.openAppStoreReviewPage() opens the App Store.
//

import UIKit

@MainActor
enum SupportContact {
    /// Where "Contact Us" feedback is delivered.
    static let recipient = "ali.muhammadimran@gmail.com"

    /// Opens the user's mail app with the recipient, subject, and a diagnostics
    /// signature pre-filled. The compose cursor sits above the signature so the
    /// user types their message first. If no app can handle the message (e.g. no
    /// mail client is installed), the address is copied to the clipboard and
    /// `onCopiedToClipboard` is called so the caller can confirm to the user.
    static func composeFeedbackEmail(onCopiedToClipboard: @escaping () -> Void) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Al-Thaqalayn Feedback"),
            URLQueryItem(name: "body", value: "\n\n\(signature)")
        ]
        guard let url = components.url else {
            copyAddressToClipboard(then: onCopiedToClipboard)
            return
        }
        UIApplication.shared.open(url) { success in
            if !success {
                copyAddressToClipboard(then: onCopiedToClipboard)
            }
        }
    }

    private static func copyAddressToClipboard(then notify: @escaping () -> Void) {
        UIPasteboard.general.string = recipient
        notify()
    }

    /// e.g. "Sent from Al-Thaqalayn v6.5 (64) · iOS 18.5 · iPhone15,2"
    private static var signature: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        let os = UIDevice.current.systemVersion
        return "Sent from Al-Thaqalayn v\(version) (\(build)) · iOS \(os) · \(deviceModelIdentifier)"
    }

    /// Raw hardware identifier such as "iPhone15,2" (the simulator reports its
    /// host architecture instead, which is fine for a diagnostics footer).
    private static var deviceModelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce(into: "") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            identifier.append(Character(UnicodeScalar(UInt8(value))))
        }
    }
}
