// EighToBadgeWatchApp.swift
// EighToBadgeWatch
//
// Root app entry point for watchOS.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import SwiftUI

@main
struct EighToBadgeWatchApp: App {
  var body: some Scene {
    WindowGroup {
      WorkoutListView()
    }
  }
}

struct WorkoutListView: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("EighToBadge")
        .font(.headline)

      Text("Workouts")
        .font(.body)
        .foregroundColor(.gray)

      Spacer()

      Button("Start") {
        // Placeholder
      }
      .buttonStyle(.bordered)
    }
    .padding()
  }
}

#Preview {
  WorkoutListView()
}
