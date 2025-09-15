//
//  View+Extension.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 15/09/2025.
//

import SwiftUI
// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
