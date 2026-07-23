// ActiveWorkoutView.swift
// EighToBadgeWatch
//
// Placeholder for active workout view. Will be implemented after
// watchOS app builds successfully.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import SwiftUI

struct ActiveWorkoutView: View {
  var body: some View {
    VStack(spacing: 20) {
      Text("00:00")
        .font(.system(size: 48, weight: .bold, design: .monospaced))

      Text("Sled Push")
        .font(.body)
        .foregroundColor(.gray)

      Button("Next") {
        // Placeholder
      }
      .buttonStyle(.bordered)
    }
    .padding()
  }
}

#Preview {
  ActiveWorkoutView()
}
