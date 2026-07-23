// ActiveWorkoutState.swift
// EighToBadgeCore
//
// State model for an active workout session. Tracks current exercise, timing,
// and accumulated results as the user progresses through the workout.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation

public struct ActiveWorkoutState {
  public let template: WorkoutTemplate
  public var currentExerciseIndex: Int = 0
  public var elapsedSeconds: TimeInterval = 0
  public var results: [ExerciseResult] = []
  public var currentHeartRate: Int?
  public var isRunning: Bool = false

  public init(template: WorkoutTemplate) {
    self.template = template
  }

  public var currentExercise: ExercisePlan? {
    guard currentExerciseIndex < template.exercises.count else { return nil }
    return template.exercises[currentExerciseIndex]
  }

  public var isLastExercise: Bool {
    currentExerciseIndex == template.exercises.count - 1
  }

  public var progressText: String {
    "\(currentExerciseIndex + 1) / \(template.exercises.count)"
  }

  public var elapsedTimeFormatted: String {
    let hours = Int(elapsedSeconds) / 3600
    let minutes = (Int(elapsedSeconds) % 3600) / 60
    let seconds = Int(elapsedSeconds) % 60

    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%d:%02d", minutes, seconds)
    }
  }

  public mutating func advanceToNextExercise() {
    if !isLastExercise {
      currentExerciseIndex += 1
    }
  }

  public mutating func recordCurrentExerciseResult(duration: TimeInterval, avgHR: Int, maxHR: Int) {
    guard let exercise = currentExercise else { return }

    let result = ExerciseResult(
      order: currentExerciseIndex,
      name: exercise.displayName,
      kind: exercise.kind,
      targetValue: exercise.targetValue,
      unit: exercise.unit,
      duration: duration,
      avgHeartRate: avgHR,
      maxHeartRate: maxHR
    )

    results.append(result)
  }

  public var totalDuration: TimeInterval {
    results.reduce(0) { $0 + $1.duration }
  }

  public var avgHeartRate: Int {
    guard !results.isEmpty else { return 0 }
    let sum = results.reduce(0) { $0 + $1.avgHeartRate }
    return sum / results.count
  }

  public var maxHeartRate: Int {
    results.map { $0.maxHeartRate }.max() ?? 0
  }
}
