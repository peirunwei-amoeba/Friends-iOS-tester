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
    
    init(name: String, photo: Data? = nil, sortOrder: Int = 0) {
        self.name = name
        self.photo = photo
        self.sortOrder = sortOrder
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
