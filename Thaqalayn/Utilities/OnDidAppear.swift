//
//  OnDidAppear.swift
//  Thaqalayn
//
//  Runs an action when the hosting screen's appearance transition has
//  finished. SwiftUI's onAppear fires as a push begins; a screen that pushes a
//  further screen from onAppear does so while it is still sliding in, and
//  NavigationView cancels that nested link once the first transition lands
//  (the passage popped straight back to the list when opened from a bookmark).
//  A child view controller receives viewDidAppear only after the containing
//  transition completes, which is the signal this modifier exposes.
//

import SwiftUI
import UIKit

extension View {
    /// Like onAppear, but after the screen's push or present transition has
    /// completed. Fires again each time the screen reappears.
    func onDidAppear(perform action: @escaping () -> Void) -> some View {
        background(OnDidAppearController(action: action).frame(width: 0, height: 0).allowsHitTesting(false))
    }
}

private struct OnDidAppearController: UIViewControllerRepresentable {
    let action: () -> Void

    func makeUIViewController(context: Context) -> Controller { Controller(action: action) }
    func updateUIViewController(_ controller: Controller, context: Context) { controller.action = action }

    final class Controller: UIViewController {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = false
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            action()
        }
    }
}
