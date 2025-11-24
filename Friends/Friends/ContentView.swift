   //
//  ContentView.swift
//  Friends
//
//  Created by Runwei Pei on 14/11/25.
//
// Licensed under the Polyform Noncommercial License 1.0.0
// Copyright (c) 2025 PEI RUNWEI

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Pet.sortOrder) private var pets: [Pet]
    
    @State private var path = [Pet]()
    @State private var isEditing: Bool = false
    @State private var draggingPet: Pet?
    
    let layout = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    func addPet() {
        let pet = Pet(name: "Best Friend", sortOrder: pets.count)
        modelContext.insert(pet)
        path = [pet]
    }
    
    func movePet(from source: IndexSet, to destination: Int) {
        var updatedPets = pets
        updatedPets.move(fromOffsets: source, toOffset: destination)
        
        // Update sort order for all pets
        for (index, pet) in updatedPets.enumerated() {
            pet.sortOrder = index
        }
    }
    
    @ViewBuilder
    private func petCardContent(for pet: Pet) -> some View {
        if let imageData = pet.photo {
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            }
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(40)
                .foregroundStyle(.quaternary)
        }
        Spacer()
        Text(pet.name)
            .font(.title.weight(.light))
            .padding(.vertical)
    }
    
    @ViewBuilder
    private func petCard(for pet: Pet) -> some View {
        NavigationLink(value: pet) {
            VStack {
                petCardContent(for: pet)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .overlay(alignment: .topTrailing) {
                if isEditing {
                    Button(role: .destructive) {
                        modelContext.delete(pet)
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.red)
                            .symbolRenderingMode(.multicolor)
                            .padding()
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .onDrag {
            if isEditing {
                draggingPet = pet
            }
            return NSItemProvider(object: pet.id.hashValue.description as NSString)
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: layout) {
                    GridRow {
                        ForEach(pets) { pet in
                            petCard(for: pet)
                                .opacity(draggingPet == pet && isEditing ? 0.5 : 1.0)
                                .onDrop(of: [.url], delegate: PetDropDelegate(
                                    pet: pet,
                                    pets: pets,
                                    draggingPet: $draggingPet,
                                    isEditing: isEditing,
                                    modelContext: modelContext
                                ))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(pets.isEmpty ? "" : "Friends")
            .navigationDestination(for: Pet.self, destination: EditPetView.init)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add a New Pet", systemImage: "plus.circle", action: addPet)
                }
            }
            .overlay {
                if pets.isEmpty {
                    CustomContentUnavailableView(
                        icon: "person.fill.badge.plus", title: "No Friends Yet!", description: "Add a new friend to get started!")
                }
            }
        }
    }
}

struct PetDropDelegate: DropDelegate {
    let pet: Pet
    let pets: [Pet]
    @Binding var draggingPet: Pet?
    let isEditing: Bool
    let modelContext: ModelContext
    
    func performDrop(info: DropInfo) -> Bool {
        guard isEditing else { return false }
        draggingPet = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard isEditing else { return }
        guard let draggingPet = draggingPet else { return }
        guard draggingPet != pet else { return }
        
        guard let fromIndex = pets.firstIndex(of: draggingPet),
              let toIndex = pets.firstIndex(of: pet) else { return }
        
        withAnimation {
            // Swap sort orders
            let fromOrder = pets[fromIndex].sortOrder
            let toOrder = pets[toIndex].sortOrder
            
            pets[fromIndex].sortOrder = toOrder
            pets[toIndex].sortOrder = fromOrder
        }
    }
}

#Preview("Sample Data") {
    ContentView()
        .modelContainer(Pet.preview)
}

#Preview("No Data") {
    ContentView()
        .modelContainer(for: Pet.self, inMemory: true)
}
