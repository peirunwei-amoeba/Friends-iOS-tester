//
//  Pet.swift
//  Friends
//
//  Created by Runwei Pei on 14/11/25.
//
// Licensed under the Polyform Noncommercial License 1.0.0
// Copyright (c) 2025 PEI RUNWEI

import Foundation
import SwiftData

@Model
final class Pet {
    var name: String
    @Attribute(.externalStorage) var photo: Data?
    var sortOrder: Int
    var dateAdded: Date
    var notes: String
    var isFavorite: Bool
    var phoneNumber: String
    var recentMessages: [MessageRecord] = []
    
    init(name: String, photo: Data? = nil, sortOrder: Int = 0, phoneNumber: String = "") {
        self.name = name
        self.photo = photo
        self.sortOrder = sortOrder
        self.dateAdded = Date()
        self.notes = ""
        self.isFavorite = false
        self.phoneNumber = phoneNumber
        self.recentMessages = []
    }
}

struct MessageRecord: Codable, Hashable, Identifiable {
    let id: UUID
    let message: String
    let dateSent: Date
    
    init(message: String, dateSent: Date) {
        self.id = UUID()
        self.message = message
        self.dateSent = dateSent
    }
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: dateSent, relativeTo: Date())
    }
}

extension Pet {
    @MainActor
    static var preview: ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Pet.self, configurations: configuration)
        
        container.mainContext.insert(Pet(name:"Rexy", sortOrder: 0))
        container.mainContext.insert(Pet(name:"Bella", sortOrder: 1))
        container.mainContext.insert(Pet(name:"Charlie", sortOrder: 2))
        container.mainContext.insert(Pet(name:"Daisy", sortOrder: 3))
        container.mainContext.insert(Pet(name:"Fido", sortOrder: 4))
        container.mainContext.insert(Pet(name:"Gus", sortOrder: 5))
        container.mainContext.insert(Pet(name:"Mimi", sortOrder: 6))
        container.mainContext.insert(Pet(name:"Luna", sortOrder: 7))
        
        return container
    
    }
}
