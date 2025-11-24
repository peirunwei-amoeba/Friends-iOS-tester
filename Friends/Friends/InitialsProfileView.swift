//
//  InitialsProfileView.swift
//  Friends
//
//  Created by Runwei Pei on 24/11/25.
//
// Licensed under the Polyform Noncommercial License 1.0.0
// Copyright (c) 2025 PEI RUNWEI

import SwiftUI

/// A view that displays initials on a colored background, similar to iOS Contacts
struct InitialsProfileView: View {
    let name: String
    let size: CGFloat
    
    private var initials: String {
        let components = name.split(separator: " ")
        if components.isEmpty {
            return "?"
        } else if components.count == 1 {
            return String(components[0].prefix(1)).uppercased()
        } else {
            let first = components.first?.prefix(1) ?? ""
            let last = components.last?.prefix(1) ?? ""
            return "\(first)\(last)".uppercased()
        }
    }
    
    private var backgroundColor: Color {
        // Generate a consistent color based on the name
        let hash = abs(name.hashValue)
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .pink, .red, .indigo, .teal, .cyan, .mint
        ]
        return colors[hash % colors.count]
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            
            Text(initials)
                .font(.system(size: size * 0.4, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

/// A view that displays either a photo or initials for a pet
struct PetProfileImageView: View {
    let pet: Pet
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(pet: Pet, size: CGFloat, cornerRadius: CGFloat? = nil) {
        self.pet = pet
        self.size = size
        self.cornerRadius = cornerRadius ?? size * 0.2 // Default to 20% of size
    }
    
    var body: some View {
        if let imageData = pet.photo, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            InitialsProfileView(name: pet.name, size: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

#Preview("Single Initial") {
    InitialsProfileView(name: "John", size: 100)
}

#Preview("Two Initials") {
    InitialsProfileView(name: "John Doe", size: 100)
}

#Preview("Empty Name") {
    InitialsProfileView(name: "", size: 100)
}

#Preview("Pet Profile - No Photo") {
    PetProfileImageView(
        pet: Pet(name: "Bella Smith"),
        size: 200,
        cornerRadius: 40
    )
}
