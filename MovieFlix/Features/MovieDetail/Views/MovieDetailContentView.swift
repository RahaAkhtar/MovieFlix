//
//  MovieDetailContentView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import Kingfisher

struct MovieDetailContentView: View {
    let movie: Movie
    let onShowDetails: () -> Void
    let onEditImage: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Quick Actions
            HStack(spacing: 20) {
                ActionButton(
                    icon: "info.circle.fill",
                    label: "Details",
                    color: .blue,
                    action: onShowDetails
                )
                
                ActionButton(
                    icon: "photo.fill",
                    label: "Edit Cover",
                    color: .purple,
                    action: onEditImage
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
            
            // Info Sections
            VStack(spacing: 20) {
                if let overview = movie.overview, !overview.isEmpty {
                    InfoSection(title: "Story", icon: "text.quote") {
                        Text(overview)
                            .font(.body)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                }
                
                if let staff = movie.staff, !staff.isEmpty {
                    InfoSection(title: "Cast & Crew", icon: "person.2.fill") {
                        StaffListView(staff: staff)
                    }
                    .padding(.horizontal, 16)
                }
                
                AdditionalMovieInfoView(movie: movie)
                    .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .offset(y: -20)
    }
}
