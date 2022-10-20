//
//  CoreDataToCSVDemoApp.swift
//  CoreDataToCSVDemo
//
//  Created by Don Mag on 10/20/22.
//

import SwiftUI

@main
struct CoreDataToCSVDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
