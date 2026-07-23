// WorkoutTemplate.swift
// EighToBadgeCore
//
// Model representing a reusable workout template. Contains a list of exercises
// that can be run on the watch and tracked as a session.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftData

@Model
public final class WorkoutTemplate: Identifiable {
  public var id: UUID
  public var name: String
  public var createdDate: Date
  public var isStandardHyrox: Bool
  public var exercises: [ExercisePlan] = []

  public init(
    id: UUID = UUID(),
    name: String,
    createdDate: Date = Date(),
    isStandardHyrox: Bool = false,
    exercises: [ExercisePlan] = []
  ) {
    self.id = id
    self.name = name
    self.createdDate = createdDate
    self.isStandardHyrox = isStandardHyrox
    self.exercises = exercises
  }

  public var totalRunDistance: Double {
    exercises
      .filter { $0.kind == .run }
      .reduce(0) { $0 + $1.targetValue }
  }

  public var stationCount: Int {
    exercises.filter { $0.kind == .station }.count
  }

  public var exerciseCount: Int {
    exercises.count
  }
}
