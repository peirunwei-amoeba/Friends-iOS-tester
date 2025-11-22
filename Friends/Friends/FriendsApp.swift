//
//  FriendsApp.swift
//  Friends
//
//  Created by Runwei Pei on 14/11/25.
//

import SwiftUI
import SwiftData

@main
struct FriendsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Pet.self)
        }
    }
}
