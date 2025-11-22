   //
//  ContentView.swift
//  Friends
//
//  Created by Runwei Pei on 14/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var pets: [Pet]
    
    @State private var path = 
    
    let layout = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    func addPet() {
        let pet = Pet(name: "Best Friend")
        modelContext.insert(pet)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: layout) {
                    GridRow {
                        ForEach(pets) { pet in
                            NavigationLink(destination: EmptyView()) {
                                VStack {
                                    if let imageData = pet.photo {
                                        if let image = UIImage(data: imageData) {
                                            Image(uiImage: image)
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
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }.padding(.horizontal)
                
            }
        .navigationTitle(pets.isEmpty ? "" : "Friends")
        .toolbar{
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
#Preview("Sample Data") {
    ContentView()
        .modelContainer(Pet.preview)
}

#Preview("No Data") {
    ContentView()
        .modelContainer(for: Pet.self, inMemory: true)
}
