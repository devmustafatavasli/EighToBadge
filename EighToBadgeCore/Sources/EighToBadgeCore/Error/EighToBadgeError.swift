// EighToBadgeError.swift
// EighToBadgeCore
//
// Typed error enum for all errors that can occur in the app. Conforms to LocalizedError
// for user-facing error messages.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation

public enum EighToBadgeError: LocalizedError, Sendable {
  case workoutNotFound
  case invalidExercise
  case healthKitAccessDenied
  case healthKitNotAvailable
  case cloudKitSyncFailed(String)
  case persistenceError(String)
  case invalidWorkoutTemplate

  public var errorDescription: String? {
    switch self {
    case .workoutNotFound:
      return "Workout not found."
    case .invalidExercise:
      return "Invalid exercise configuration."
    case .healthKitAccessDenied:
      return "HealthKit access was denied. Enable it in Settings to track heart rate."
    case .healthKitNotAvailable:
      return "HealthKit is not available on this device."
    case .cloudKitSyncFailed(let reason):
      return "Sync failed: \(reason)"
    case .persistenceError(let reason):
      return "Storage error: \(reason)"
    case .invalidWorkoutTemplate:
      return "This workout template is invalid."
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .workoutNotFound:
      return "Try creating a new workout or selecting an existing one."
    case .invalidExercise:
      return "Check the exercise settings and try again."
    case .healthKitAccessDenied:
      return "Open Settings > Health and grant EighToBadge access to heart rate data."
    case .healthKitNotAvailable:
      return "This device does not support heart rate tracking."
    case .cloudKitSyncFailed:
      return "Check your internet connection and try again."
    case .persistenceError:
      return "Try restarting the app."
    case .invalidWorkoutTemplate:
      return "Delete and recreate this workout."
    }
  }
}
