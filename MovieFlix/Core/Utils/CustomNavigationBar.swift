//
//  CustomNavigationBar.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

struct CustomNavigationBar: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
