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
    @Bindable var pet: Pet
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var originalName: String = ""
    
    var body: some View {
        Form{
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
            
            // MARK: - BUTTON
            Button {
                dismiss()
            }label: {
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
            
        }
        .padding(.bottom)
        
        
        .listStyle(.plain)
        .navigationTitle("Edit \(pet.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            originalName = pet.name
        }
        .navigationBarBackButtonHidden()
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
