//
//  SnapItApp.swift
//  SnapIt
//
//  Created by Prince on 18/07/26.
//

import SwiftUI

@main
struct SnapItApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(appState)
        }
    }
}
