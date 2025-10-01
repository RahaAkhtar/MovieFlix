//
//  NoDataView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 02/10/2025.
//

import SwiftUI

// MARK: - Reusable NoDataView
struct NoDataView: View {
    let icon: String
       let title: String
       let message: String
       let buttonTitle: String?
       let buttonAction: (() -> Void)?
       let frame: CGSize?
       
       init(icon: String, title: String, message: String, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil, frame: CGSize? = nil) {
           self.icon = icon
           self.title = title
           self.message = message
           self.buttonTitle = buttonTitle
           self.buttonAction = buttonAction
           self.frame = frame
       }
    
    // Pre-configured for common use cases
    static func movieNoData(frame: CGSize, dismissAction: @escaping () -> Void) -> NoDataView {
        NoDataView(
            icon: "film",
            title: "No Content Available",
            message: "This movie doesn't have any details or images yet.",
            buttonTitle: "Go Back",
            buttonAction: dismissAction,
            frame: frame
        )
    }
    
    static func searchNoData() -> NoDataView {
        NoDataView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search terms or filters."
        )
    }
    
    static func networkError(retryAction: @escaping () -> Void) -> NoDataView {
        NoDataView(
            icon: "wifi.exclamationmark",
            title: "Connection Error",
            message: "Please check your internet connection and try again.",
            buttonTitle: "Retry",
            buttonAction: retryAction
        )
    }
    
    static func favoritesEmpty() -> NoDataView {
        NoDataView(
            icon: "heart",
            title: "No Favorites Yet",
            message: "Movies you mark as favorite will appear here."
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                Button(buttonTitle, action: buttonAction)
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ifLet(frame) { view, size in
            view.frame(width: size.width, height: size.height)
        }
        .background(Color(.systemBackground))
    }
}

