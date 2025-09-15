//
//  MovieFlixLogo.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 15/09/2025.
//


import SwiftUI

struct MovieFlixLogo: View {
    var body: some View {
        ZStack {
            // Background gradient
            Circle()
                .fill(LinearGradient(
                    colors: [
                        Color(red: 106/255, green: 13/255, blue: 173/255),
                        Color(red: 25/255, green: 25/255, blue: 112/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 300, height: 300)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Outer film reel circle
            Circle()
                .stroke(Color.white, lineWidth: 12)
                .frame(width: 220, height: 220)
            
            // Inner film reel circle
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 6)
                .frame(width: 180, height: 180)
            
            // Film reel spokes
            ForEach(0..<8) { index in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 4, height: 100)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            
            // Center circle
            Circle()
                .fill(Color.yellow)
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
            
            // Play button
            Triangle()
                .fill(Color.white)
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(90))
                .offset(x: 3)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct LogoWithText: View {
    var body: some View {
        VStack(spacing: 20) {
            MovieFlixLogo()
            
            Text("MOVIEFLIX")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 215/255, blue: 0/255),
                            Color(red: 255/255, green: 255/255, blue: 200/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 30/255, green: 30/255, blue: 60/255),
                    Color(red: 15/255, green: 15/255, blue: 30/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Previews
struct MovieFlixLogo_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Icon only (1024x1024 style)
            MovieFlixLogo()
                .frame(width: 300, height: 300)
            
            // Logo with text
            LogoWithText()
                .frame(width: 400, height: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Usage Example
struct LogoPreview: View {
    var body: some View {
        VStack {
            LogoWithText()
                .frame(width: 400, height: 500)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// To use in your app:
// Just add LogoPreview() to any view or preview
#Preview("Loading LogoPreview") {
    LogoPreview()
}
