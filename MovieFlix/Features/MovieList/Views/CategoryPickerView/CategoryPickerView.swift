//
//  CategoryPickerView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    let onCategorySelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryButton(
                            title: APIUrls.Categories.displayName(for: category),
                            isSelected: selectedCategory == category,
                            action: { onCategorySelected(category) }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
            
            Divider()
        }
    }
}

// Category Button Component
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .cornerRadius(20)
        }
    }
}
