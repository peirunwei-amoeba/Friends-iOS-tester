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
    @State private var searchText = ""
    
    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    // Adaptive layout that responds to device size and orientation
    private var adaptiveColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 16)]
    }
    
    var filteredPets: [Pet] {
        if searchText.isEmpty {
            return pets
        } else {
            return pets.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func addPet() {
        let pet = Pet(name: "Best Friend", sortOrder: pets.count)
        modelContext.insert(pet)
        path = [pet]
    }
    
    func duplicatePet(_ original: Pet) {
        let duplicate = Pet(
            name: "\(original.name) Copy",
            photo: original.photo,
            sortOrder: pets.count
        )
        modelContext.insert(duplicate)
        path = [duplicate]
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
                    .scaledToFill() // Changed from scaledToFit for better appearance
                    .frame(height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            }
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(40)
                .foregroundStyle(.quaternary)
                .frame(height: 200)
        }
        Spacer()
        Text(pet.name)
            .font(.title.weight(.light))
            .padding(.vertical)
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private func petCard(for pet: Pet) -> some View {
        NavigationLink(value: pet) {
            VStack {
                petCardContent(for: pet)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 280, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .shadow(color: .black.opacity(isEditing ? 0.05 : 0.08), radius: 8, x: 0, y: 4)
            .scaleEffect(draggingPet == pet && isEditing ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEditing)
            .overlay(alignment: .topTrailing) {
                if isEditing {
                    Button(role: .destructive) {
                        impactMedium.impactOccurred()
                        withAnimation {
                            modelContext.delete(pet)
                        }
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.red)
                            .symbolRenderingMode(.multicolor)
                            .padding()
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .overlay(alignment: .topLeading) {
                if pet.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .padding(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .overlay {
                // Visual indicator for draggable state
                if isEditing && draggingPet == nil {
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .strokeBorder(.blue.opacity(0.3), lineWidth: 2)
                        .animation(.easeInOut(duration: 0.3), value: isEditing)
                }
            }
        }
        .buttonStyle(.plain) // Prevents default button animation interference
        .foregroundStyle(.primary)
        .accessibilityLabel("Card for \(pet.name)")
        .accessibilityHint(isEditing ? "Double tap to edit, drag to reorder" : "Double tap to view details")
        .contextMenu {
            Button {
                path = [pet]
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                withAnimation {
                    pet.isFavorite.toggle()
                }
                selectionFeedback.selectionChanged()
            } label: {
                Label(pet.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: pet.isFavorite ? "heart.slash" : "heart")
            }
            
            Button {
                duplicatePet(pet)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            
            Divider()
            
            Button(role: .destructive) {
                withAnimation {
                    modelContext.delete(pet)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .onDrag {
            if isEditing {
                draggingPet = pet
                impactLight.impactOccurred()
            }
            return NSItemProvider(object: pet.id.hashValue.description as NSString)
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                    ForEach(filteredPets) { pet in
                        petCard(for: pet)
                            .opacity(draggingPet == pet && isEditing ? 0.5 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: draggingPet == pet)
                            .onDrop(of: [.url], delegate: PetDropDelegate(
                                pet: pet,
                                pets: pets,
                                draggingPet: $draggingPet,
                                isEditing: isEditing,
                                modelContext: modelContext
                            ))
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Friends")
            .navigationDestination(for: Pet.self, destination: EditPetView.init)
            .searchable(text: $searchText, prompt: "Search friends")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isEditing.toggle()
                        }
                        impactMedium.impactOccurred()
                    } label: {
                        Label(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark.circle.fill" : "arrow.up.arrow.down.circle")
                    }
                    .tint(isEditing ? .green : .primary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add a New Pet", systemImage: "plus.circle", action: addPet)
                        .disabled(isEditing)
                }
            }
            .safeAreaInset(edge: .top) {
                if isEditing {
                    Text("Drag cards to reorder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .overlay {
                if pets.isEmpty {
                    ContentUnavailableView {
                        Label("No Friends Yet!", systemImage: "person.fill.badge.plus")
                    } description: {
                        Text("Add a new friend to get started!")
                    } actions: {
                        Button("Add Friend", systemImage: "plus.circle.fill", action: addPet)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    }
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
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            // Properly reorder all pets
            var updatedPets = pets
            let movedPet = updatedPets.remove(at: fromIndex)
            updatedPets.insert(movedPet, at: toIndex)
            
            // Update sort order for all pets
            for (index, pet) in updatedPets.enumerated() {
                pet.sortOrder = index
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: isEditing ? .move : .cancel)
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
