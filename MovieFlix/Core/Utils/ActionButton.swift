//
//  ActionButton.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 80)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}
