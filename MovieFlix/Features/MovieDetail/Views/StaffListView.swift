//
//  StaffListView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI

struct StaffListView: View {
    let staff: [String]
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(staff, id: \.self) { member in
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(member)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}

//#Preview {
//    StaffListView(staff: ["Christopher Nolan", "Leonardo DiCaprio", "Marion Cotillard"])
//}
