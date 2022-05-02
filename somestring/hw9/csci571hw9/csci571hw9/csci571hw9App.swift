//
//  csci571hw9App.swift
//  csci571hw9
//
//  Created by Jerry Lee on 4/5/22.
//

import SwiftUI

@main
struct csci571hw9App: App {
    let persistenceController = PersistenceController.shared
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
