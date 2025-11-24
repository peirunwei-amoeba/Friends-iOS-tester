//
//  EditPetView.swift
//  Friends
//
//  Created by Runwei Pei on 21/11/25.
//
// Licensed under the Polyform Noncommercial License 1.0.0
// Copyright (c) 2025 PEI RUNWEI

import SwiftUI
import SwiftData
import PhotosUI

struct EditPetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var pet: Pet
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var originalName: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name
        case phoneNumber
    }
    
    var body: some View {
        Form {
            // MARK: - IMAGE
            if let imageData = pet.photo {
                if let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 250, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        .frame(maxWidth: .infinity)
                    
                }
            } else {
                CustomContentUnavailableView(
                    icon: "person.fill.badge.plus", title: "No Photo Yet!", description: "Add a photo of your good friend below to make them stand out!"
                )
                
                .padding(.top)
            }
            // MARK: - PHOTO PICKER
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.badge.plus")
                        .foregroundStyle(.tint)
                    Text("Select a Photo")
                }
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            
            // MARK: - TEXT FIELD
            TextField("Name", text: $pet.name)
                .textFieldStyle(.automatic)
                .font(.largeTitle.weight(.light))
                .padding(.vertical)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .listRowSeparator(.hidden)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .phoneNumber
                }
            
            // MARK: - PHONE NUMBER
            TextField("Phone Number (Optional)", text: $pet.phoneNumber)
                .textFieldStyle(.automatic)
                .font(.title3)
                .keyboardType(.phonePad)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .listRowSeparator(.hidden)
                .focused($focusedField, equals: .phoneNumber)
            
            // MARK: - BUTTON
            Button {
                // Dismiss keyboard first
                focusedField = nil
                
                // Explicitly save the context
                do {
                    try modelContext.save()
                    print("Successfully saved pet: \(pet.name)")
                } catch {
                    print("Error saving context: \(error)")
                }
                
                dismiss()
            } label: {
                Text("Save")
                    .font(.title3.weight(.medium))
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .listRowSeparator(.hidden)
            .shadow(
                color: pet.name != originalName ? .black.opacity(0.2) : .clear,
                radius: pet.name != originalName ? 8 : 0,
                x: 0,
                y: pet.name != originalName ? 4 : 0
            )
            .animation(.easeInOut(duration: 0.3), value: pet.name != originalName)
            //.disabled(pet.name == originalName)
            
            // Add bottom spacer for better scrolling experience
            Color.clear
                .frame(height: 100)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .listStyle(.plain)
        .navigationTitle("Edit \(pet.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            originalName = pet.name
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    // If this is a new pet with default name, delete it
                    if pet.name == "Best Friend" && originalName == "Best Friend" {
                        modelContext.delete(pet)
                    }
                    dismiss()
                }
            }
            
            // Add keyboard dismiss button when keyboard is active
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .fontWeight(.bold)
                .tint(.blue)
            }
        }
        .onChange(of: photosPickerItem) {
            Task {
                pet.photo = try? await photosPickerItem?.loadTransferable(type: Data.self)
            }
        }
    }
}

#Preview {
    NavigationStack {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Pet.self, configurations: configuration)
            let sampleData = Pet(name: "Daisy")
                                                                     
            
            
            return EditPetView(pet: sampleData)
                .modelContainer(container)
        } catch {
            fatalError("Could not load preview data. \(error.localizedDescription)")
        }
    }
}
