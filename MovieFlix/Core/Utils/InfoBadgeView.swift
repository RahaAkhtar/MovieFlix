//
//  InfoBadgeView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

struct InfoBadgeView: View {
    let icon: String
    let text: String
    let iconColor: Color
    let textColor: Color
    let iconSize: CGFloat
    let textSize: CGFloat
    let textWeight: Font.Weight
    
    init(
        icon: String,
        text: String,
        iconColor: Color = .white.opacity(0.9),
        textColor: Color = .white,
        iconSize: CGFloat = 14,
        textSize: CGFloat = 16,
        textWeight: Font.Weight = .medium
    ) {
        self.icon = icon
        self.text = text
        self.iconColor = iconColor
        self.textColor = textColor
        self.iconSize = iconSize
        self.textSize = textSize
        self.textWeight = textWeight
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: iconSize))
            
            Text(text)
                .font(.system(size: textSize, weight: textWeight))
                .foregroundColor(textColor)
        }
    }
}

extension InfoBadgeView {
    // For ratings
    static func rating(_ value: Double) -> InfoBadgeView {
        InfoBadgeView(
            icon: "star.fill",
            text: String(format: "%.1f", value),
            iconColor: .yellow,
            textWeight: .semibold
        )
    }
    
    // For dates/years
    static func year(_ value: String) -> InfoBadgeView {
        InfoBadgeView(
            icon: "calendar",
            text: value
        )
    }
    
    // For media types
    static func mediaType(_ value: String) -> InfoBadgeView {
        InfoBadgeView(
            icon: "tv",
            text: value
        )
    }
    
    // For runtime/duration
    static func runtime(_ minutes: Int) -> InfoBadgeView {
        InfoBadgeView(
            icon: "clock",
            text: "\(minutes) min"
        )
    }
    
    // For budget
    static func budget(_ amount: Double) -> InfoBadgeView {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        return InfoBadgeView(
            icon: "dollarsign.circle",
            text: formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
        )
    }
}
