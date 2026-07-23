// ExerciseType.swift
// EighToBadgeCore
//
// Enum representing all possible exercises (runs and stations) in a Hyrox workout.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation

public enum ExerciseType: String, Codable, Sendable, CaseIterable {
  case run1km = "1k Run"
  case sledPush = "Sled Push"
  case wallBalls = "Wall Balls"
  case rowing500m = "Rowing 500m"
  case ropeClinb = "Rope Climb"
  case cargo = "Cargo"
  case wallRun = "Wall Run"
  case burpee = "Burpee Broad Jump"
  case battleRopes = "Battle Ropes"

  public var displayName: String {
    self.rawValue
  }

  public var kind: ExerciseKind {
    switch self {
    case .run1km:
      return .run
    default:
      return .station
    }
  }

  public var defaultDistance: Double {
    switch self {
    case .run1km:
      return 1.0
    case .sledPush, .rowing500m:
      return 0.5
    default:
      return 0.0
    }
  }

  public var defaultReps: Int {
    switch self {
    case .wallBalls, .ropeClinb, .burpee:
      return 10
    case .battleRopes:
      return 40
    default:
      return 0
    }
  }

  public var defaultWeight: Double {
    switch self {
    case .sledPush:
      return 100.0
    case .wallBalls:
      return 14.0
    default:
      return 0.0
    }
  }
}
