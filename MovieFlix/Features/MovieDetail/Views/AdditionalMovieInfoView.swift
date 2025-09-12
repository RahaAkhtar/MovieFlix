//
//  AdditionalMovieInfoView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

struct AdditionalMovieInfoView: View {
    let movie: Movie
    
    var body: some View {
        InfoSection(title: "Details", icon: "info.circle.fill") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                if let runtime = movie.runtime {
                    InfoItem(icon: "clock.fill", title: "Runtime", value: "\(runtime) min")
                }
                
                if let budget = movie.budget, budget > 0 {
                    InfoItem(icon: "dollarsign.circle.fill", title: "Budget", value: "$\(budget.formatted())")
                }
                
                InfoItem(icon: "film.fill", title: "Type", value: movie.mediaType)
                
                if let releaseDate = movie.releaseDate {
                    InfoItem(icon: "calendar.circle.fill", title: "Released", value: releaseDate)
                }
            }
        }
    }
}
