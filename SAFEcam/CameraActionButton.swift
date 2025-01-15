//
//  CameraActionButton.swift
//  SAFEcam
//
//  Created by 정다은 on 1/15/25.
//

import SwiftUI

struct CameraActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.largeTitle)
                Text(label)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
