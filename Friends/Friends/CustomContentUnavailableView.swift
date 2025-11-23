//
//  CustomContentUnavailableView.swift
//  Friends
//
//  Created by Runwei Pei on 14/11/25.
//
// Licensed under the Polyform Noncommercial License 1.0.0
// Copyright (c) 2025 PEI RUNWEI

import SwiftUI

struct CustomContentUnavailableView: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        ContentUnavailableView{
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 96)
            
            Text(title)
                .font(.title)
        } description:{
            Text(description)
        }
        .foregroundStyle(.tertiary)
    }
}
#Preview {
    CustomContentUnavailableView(
        icon: "person.crop.circle.badge.plus", 
        title: "No Photos",
        description: "Add a photo to get started"
    )

}
