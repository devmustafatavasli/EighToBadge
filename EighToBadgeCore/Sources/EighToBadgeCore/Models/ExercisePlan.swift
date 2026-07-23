// ExercisePlan.swift
// EighToBadgeCore
//
// Model representing a single exercise within a workout template. Includes order,
// exercise type, and customizable distance/reps/weight.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftData

@Model
public final class ExercisePlan: Identifiable, Sendable {
  public var id: UUID
  public var order: Int
  public var kind: ExerciseKind
  public var type: ExerciseType
  public var targetValue: Double
  public var unit: String

  public init(
    id: UUID = UUID(),
    order: Int,
    kind: ExerciseKind,
    type: ExerciseType,
    targetValue: Double,
    unit: String
  ) {
    self.id = id
    self.order = order
    self.kind = kind
    self.type = type
    self.targetValue = targetValue
    self.unit = unit
  }

  public var displayName: String {
    type.displayName
  }
}
