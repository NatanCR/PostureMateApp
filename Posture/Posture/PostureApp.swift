//
//  PostureApp.swift
//  Posture
//
//  Created by Natan Camargo Rodrigues on 10/1/2025.
//

import SwiftUI
import SwiftData

@main
struct PostureApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    init() {
        _ = MonitorManager.shared //init when reopen app
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
//        .modelContainer(sharedModelContainer)
    }
}
