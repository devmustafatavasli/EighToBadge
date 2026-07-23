// ActiveWorkoutView.swift
// EighToBadgeWatch
//
// Main UI for active workout on watchOS. Displays timer, progress ring,
// current exercise, heart rate, and gesture-based controls.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import SwiftUI
import EighToBadgeCore

struct ActiveWorkoutView: View {
  @State var viewModel: ActiveWorkoutViewModel
  @State private var isRunning = false

  var body: some View {
    ZStack {
      // Background
      Color.black.ignoresSafeArea()

      VStack(spacing: 12) {
        // Progress indicator
        Text(viewModel.workoutState.progressText)
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(.gray)

        // Large timer with ring visualization
        ZStack {
          // Outer ring (progress)
          Circle()
            .stroke(Color.gray.opacity(0.3), lineWidth: 3)

          Circle()
            .trim(
              from: 0,
              to: CGFloat(viewModel.workoutState.currentExerciseIndex) / CGFloat(max(1, viewModel.workoutState.template.exercises.count))
            )
            .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .rotationEffect(.degrees(-90))

          // Timer text
          VStack(spacing: 4) {
            Text(viewModel.workoutState.elapsedTimeFormatted)
              .font(.system(size: 48, weight: .bold, design: .monospaced))
              .foregroundColor(.white)

            if let hr = viewModel.workoutState.currentHeartRate {
              HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                  .font(.system(size: 12))
                  .foregroundColor(.red)
                Text("\(hr)")
                  .font(.system(size: 14, weight: .semibold))
              }
              .foregroundColor(.white)
            }
          }
        }
        .frame(height: 140)
        .padding(.vertical, 8)

        // Current exercise name
        if let exercise = viewModel.workoutState.currentExercise {
          VStack(spacing: 4) {
            Text(exercise.displayName)
              .font(.system(size: 14, weight: .semibold))
              .foregroundColor(.white)

            Text("\(Int(exercise.targetValue)) \(exercise.unit)")
              .font(.system(size: 12))
              .foregroundColor(.gray)
          }
          .multilineTextAlignment(.center)
        }

        // Controls: gesture hint + manual button
        VStack(spacing: 8) {
          Text("Double Tap to advance")
            .font(.system(size: 11))
            .foregroundColor(.gray)

          Button(action: {
            viewModel.advanceExercise()
          }) {
            Text("Next")
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
              .background(Color.green)
              .cornerRadius(6)
          }
          .handGestureShortcut(.primaryAction) {
            viewModel.advanceExercise()
          }
        }
        .padding(.top, 8)

        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)

      // Summary overlay
      if viewModel.showSummary {
        SummaryView(viewModel: viewModel)
      }
    }
    .onAppear {
      viewModel.startWorkout()
    }
    .onDisappear {
      viewModel.pauseWorkout()
    }
  }
}

struct SummaryView: View {
  @State var viewModel: ActiveWorkoutViewModel

  var body: some View {
    ZStack {
      Color.black.opacity(0.9).ignoresSafeArea()

      VStack(spacing: 16) {
        Text("Workout Complete")
          .font(.system(size: 18, weight: .bold))
          .foregroundColor(.green)

        VStack(spacing: 12) {
          HStack {
            Text("Time:")
            Spacer()
            Text(formatTime(viewModel.workoutState.totalDuration))
              .font(.system(.body, design: .monospaced))
          }

          HStack {
            Text("Avg HR:")
            Spacer()
            Text("\(viewModel.workoutState.avgHeartRate)")
          }

          HStack {
            Text("Max HR:")
            Spacer()
            Text("\(viewModel.workoutState.maxHeartRate)")
          }
        }
        .font(.system(size: 12))
        .foregroundColor(.white)

        Spacer()

        Button(action: {
          Task {
            await viewModel.saveAndDismiss()
          }
        }) {
          Text("Save")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.green)
            .cornerRadius(6)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 20)
    }
  }

  private func formatTime(_ interval: TimeInterval) -> String {
    let hours = Int(interval) / 3600
    let minutes = (Int(interval) % 3600) / 60
    let seconds = Int(interval) % 60

    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%d:%02d", minutes, seconds)
    }
  }
}

#Preview {
  let template = WorkoutTemplate(name: "Test", exercises: [])
  let repo = WorkoutSessionRepository(modelContext: ModelContext(ModelContainer(inMemoryOnly: true)))
  let healthKit = HealthKitService()

  return ActiveWorkoutView(
    viewModel: ActiveWorkoutViewModel(
      template: template,
      healthKitService: healthKit,
      sessionRepository: repo
    )
  )
}
