//
//  MovieListRow.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

struct MovieListRow: View {
    let movie: Movie
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
                    .overlay(
                        Image(systemName: "film")
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 60, height: 90)
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                if let year = movie.year {
                    Text("Year: \(year)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text("Type: \(movie.mediaType)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            VStack {
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(getRatingColor(movie.voteAverage))
                    )
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // Makes entire area tappable
    }
    
    // Helper function to get color based on rating
    private func getRatingColor(_ rating: Double) -> Color {
        switch rating {
        case 8.0...:
            return .green
        case 6.0..<8.0:
            return .orange
        default:
            return .red
        }
    }
}
