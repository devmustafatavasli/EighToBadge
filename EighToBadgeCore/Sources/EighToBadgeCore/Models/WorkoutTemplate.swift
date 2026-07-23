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
  @Relationship(deleteRule: .cascade, inverse: \ExercisePlan.template)
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

  public static func standardHyrox() -> WorkoutTemplate {
    let runs = (0..<8).map { _ in
      ExercisePlan(
        order: 0,
        kind: .run,
        type: .run1km,
        targetValue: 1.0,
        unit: "km"
      )
    }

    let stations: [ExercisePlan] = [
      ExercisePlan(order: 1, kind: .station, type: .sledPush, targetValue: 50, unit: "m"),
      ExercisePlan(order: 2, kind: .station, type: .wallBalls, targetValue: 14, unit: "reps"),
      ExercisePlan(order: 3, kind: .station, type: .rowing500m, targetValue: 500, unit: "m"),
      ExercisePlan(order: 4, kind: .station, type: .ropeClinb, targetValue: 8, unit: "reps"),
      ExercisePlan(order: 5, kind: .station, type: .cargo, targetValue: 40, unit: "m"),
      ExercisePlan(order: 6, kind: .station, type: .wallRun, targetValue: 40, unit: "m"),
      ExercisePlan(order: 7, kind: .station, type: .burpee, targetValue: 15, unit: "reps"),
      ExercisePlan(order: 8, kind: .station, type: .battleRopes, targetValue: 40, unit: "swings"),
    ]

    var allExercises: [ExercisePlan] = []
    for i in 0..<8 {
      let runIndex = allExercises.count
      var run = runs[i]
      run.order = runIndex
      allExercises.append(run)

      let stationIndex = allExercises.count
      var station = stations[i]
      station.order = stationIndex
      allExercises.append(station)
    }

    return WorkoutTemplate(
      name: "Standard Hyrox",
      isStandardHyrox: true,
      exercises: allExercises
    )
  }
}
