//
//  BottomSheetView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import SwiftUI

struct BottomSheetView: View {
    let movie: Movie
    @Binding var isPresented: Bool
    @State private var offset: CGFloat = 0
    @GestureState private var translation: CGFloat = 0
    
    private let minHeight: CGFloat = 100
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.8
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 6)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Movie Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let overview = movie.overview {
                            Text(overview)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        if let staff = movie.staff {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cast & Crew")
                                    .font(.headline)
                                
                                ForEach(staff, id: \.self) { member in
                                    Text(member)
                                        .font(.subheadline)
                                        .padding(.vertical, 2)
                                }
                            }
                        }
                        
                        AdditionalMovieInfoView(movie: movie)
                    }
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .frame(height: maxHeight)
            .frame(maxWidth: .infinity)
            .offset(y: max(offset + translation, 0))
            .animation(.interactiveSpring(), value: isPresented)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating($translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = maxHeight * 0.4
                    if value.translation.height > snapDistance {
                        isPresented = false
                    } else {
                        offset = 0
                    }
                }
            )
            .onChange(of: isPresented) { _, newValue in
                offset = newValue ? 0 : maxHeight
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
    }
}
