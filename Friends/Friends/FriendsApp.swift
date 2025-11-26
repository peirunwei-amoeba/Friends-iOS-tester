//
//  FriendsApp.swift
//  Friends
//
//  Created by Runwei Pei on 14/11/25.
//
// Licensed under the Polyform Noncommercial License 1.0.0
// Copyright (c) 2025 PEI RUNWEI

import SwiftUI
import SwiftData

@main
struct FriendsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Pet.self])
        
        // Use a fresh configuration
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer initialized successfully")
            print("📦 Schema contains: \(schema.entities.map { $0.name })")
            return container
        } catch let error as NSError {
            print("❌ Fatal error creating ModelContainer:")
            print("   Error code: \(error.code)")
            print("   Description: \(error.localizedDescription)")
            print("   User info: \(error.userInfo)")
            
            // Delete corrupted database and try again
            print("🔄 Attempting to delete old database and create fresh one...")
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
            
            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✅ Fresh ModelContainer created successfully after cleanup")
                return container
            } catch {
                print("❌ Still failed after cleanup. Using in-memory fallback...")
                let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let fallbackContainer = try! ModelContainer(for: schema, configurations: [fallbackConfig])
                print("⚠️ Using in-memory storage - data will not persist!")
                return fallbackContainer
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
