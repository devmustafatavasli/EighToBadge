// EighToBadgeWatchApp.swift
// EighToBadgeWatch
//
// Root app entry point for watchOS.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import SwiftUI
import SwiftData
import EighToBadgeCore

@main
struct EighToBadgeWatchApp: App {
  let modelContainer: ModelContainer

  init() {
    do {
      let config = ModelConfiguration(isStoredInMemoryOnly: false)
      modelContainer = try ModelContainer(
        for: WorkoutTemplate.self, WorkoutSession.self, ExercisePlan.self, ExerciseResult.self,
        configurations: config
      )
    } catch {
      fatalError("Could not initialize ModelContainer: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(modelContainer)
    }
  }
}

struct ContentView: View {
  @State private var showWorkoutList = true

  var body: some View {
    if showWorkoutList {
      WorkoutListView()
    }
  }
}

struct WorkoutListView: View {
  var body: some View {
    VStack {
      Text("EighToBadge")
        .font(.headline)
      Text("Workouts")
        .font(.body)
    }
    .padding()
  }
}

#Preview {
  EighToBadgeWatchApp()
}
