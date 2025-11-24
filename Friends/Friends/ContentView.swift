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
    @State private var selectedSort: SortOption = .custom
    @State private var showFavoritesOnly = false
    @State private var selectedPetForQuickView: Pet?
    
    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    enum SortOption: String, CaseIterable, Identifiable {
        case custom = "Custom Order"
        case name = "Name"
        case dateAdded = "Date Added"
        case favorites = "Favorites First"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .custom: return "line.3.horizontal"
            case .name: return "textformat.abc"
            case .dateAdded: return "calendar"
            case .favorites: return "heart.fill"
            }
        }
    }
    
    // Adaptive layout that responds to device size and orientation
    private var adaptiveColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 16)]
    }
    
    var filteredAndSortedPets: [Pet] {
        var result = pets
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.phoneNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply favorites filter
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        // Apply sorting
        switch selectedSort {
        case .custom:
            result = result.sorted { $0.sortOrder < $1.sortOrder }
        case .name:
            result = result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .dateAdded:
            result = result.sorted { $0.dateAdded > $1.dateAdded }
        case .favorites:
            result = result.sorted { 
                if $0.isFavorite == $1.isFavorite {
                    return $0.sortOrder < $1.sortOrder
                }
                return $0.isFavorite && !$1.isFavorite
            }
        }
        
        return result
    }
    
    var favoriteCount: Int {
        pets.filter { $0.isFavorite }.count
    }
    
    var statisticsText: String {
        if pets.isEmpty { return "" }
        let total = pets.count
        let favorites = favoriteCount
        if favorites > 0 {
            return "\(total) friend\(total == 1 ? "" : "s") • \(favorites) favorite\(favorites == 1 ? "" : "s")"
        }
        return "\(total) friend\(total == 1 ? "" : "s")"
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
            sortOrder: pets.count,
            phoneNumber: original.phoneNumber
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
        Button {
            path = [pet]
        } label: {
            VStack {
                petCardContent(for: pet)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 280, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .shadow(color: .black.opacity(isEditing ? 0.05 : 0.08), radius: 8, x: 0, y: 4)
            .scaleEffect(draggingPet == pet && isEditing ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEditing)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: draggingPet == pet)
            .overlay(alignment: .topTrailing) {
                if isEditing {
                    Button(role: .destructive) {
                        impactMedium.impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
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
                // Always-visible favorite button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        pet.isFavorite.toggle()
                    }
                    impactLight.impactOccurred()
                } label: {
                    Image(systemName: pet.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(pet.isFavorite ? .red : .primary)
                        .padding(10)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .symbolEffect(.bounce, value: pet.isFavorite)
                }
                .padding(8)
                .buttonStyle(.plain)
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
        .buttonStyle(.plain)
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
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
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
                VStack(spacing: 16) {
                    // Statistics and Filter Bar
                    if !pets.isEmpty {
                        HStack(spacing: 12) {
                            // Statistics
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(statisticsText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            
                            Spacer()
                            
                            // Sort Menu
                            Menu {
                                Picker("Sort By", selection: $selectedSort) {
                                    ForEach(SortOption.allCases) { option in
                                        Label(option.rawValue, systemImage: option.icon)
                                            .tag(option)
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: selectedSort.icon)
                                        .font(.caption)
                                    Text(selectedSort == .custom ? "Sort" : selectedSort.rawValue)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                                .foregroundStyle(.primary)
                            }
                            .onChange(of: selectedSort) { _, _ in
                                selectionFeedback.selectionChanged()
                            }
                            
                            // Favorites Filter Toggle
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showFavoritesOnly.toggle()
                                }
                                selectionFeedback.selectionChanged()
                            } label: {
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .font(.caption)
                                    .frame(width: 28, height: 28)
                                    .background(showFavoritesOnly ? Color.red.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .strokeBorder(showFavoritesOnly ? Color.red : Color.secondary.opacity(0.3), lineWidth: 1.5)
                                    }
                            }
                            .foregroundStyle(showFavoritesOnly ? .red : .secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Grid
                    LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                        ForEach(filteredAndSortedPets) { pet in
                            petCard(for: pet)
                                .opacity(draggingPet == pet && isEditing ? 0.5 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: draggingPet == pet)
                                .transition(.scale.combined(with: .opacity))
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
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: filteredAndSortedPets.map { $0.id })
                }
            }
            .navigationTitle("Friends")
            .navigationDestination(for: Pet.self, destination: EditPetView.init)
            .searchable(text: $searchText, prompt: "Search friends")
            .onAppear {
                print("📊 ContentView appeared. Total pets: \(pets.count)")
                for pet in pets {
                    print("  - \(pet.name) (phone: \(pet.phoneNumber))")
                }
            }
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
                    HStack(spacing: 8) {
                        Image(systemName: "hand.draw.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text("Drag cards to reorder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.blue.opacity(0.1))
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
                } else if filteredAndSortedPets.isEmpty {
                    ContentUnavailableView {
                        Label(showFavoritesOnly ? "No Favorite Friends" : "No Results", 
                              systemImage: showFavoritesOnly ? "heart.slash" : "magnifyingglass")
                    } description: {
                        Text(showFavoritesOnly ? "Mark some friends as favorites to see them here." : "Try adjusting your search.")
                    } actions: {
                        if showFavoritesOnly {
                            Button("Show All Friends") {
                                withAnimation {
                                    showFavoritesOnly = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
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
