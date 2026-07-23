// WorkoutSession.swift
// EighToBadgeCore
//
// Model representing a completed workout session. Records the template used,
// date, total duration, and individual exercise results with heart rate data.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftData

@Model
public final class WorkoutSession: Identifiable, Sendable {
  public var id: UUID
  public var date: Date
  public var templateName: String
  public var isStandardHyrox: Bool
  public var totalDuration: TimeInterval
  @Relationship(deleteRule: .cascade)
  public var results: [ExerciseResult] = []

  public init(
    id: UUID = UUID(),
    date: Date = Date(),
    templateName: String,
    isStandardHyrox: Bool = false,
    totalDuration: TimeInterval = 0,
    results: [ExerciseResult] = []
  ) {
    self.id = id
    self.date = date
    self.templateName = templateName
    self.isStandardHyrox = isStandardHyrox
    self.totalDuration = totalDuration
    self.results = results
  }

  public var totalDurationFormatted: String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: totalDuration) ?? "0:00:00"
  }

  public var avgHeartRate: Int {
    guard !results.isEmpty else { return 0 }
    let sum = results.reduce(0) { $0 + $1.avgHeartRate }
    return sum / results.count
  }

  public var maxHeartRate: Int {
    results.map { $0.maxHeartRate }.max() ?? 0
  }

  public var runResults: [ExerciseResult] {
    results.filter { $0.kind == .run }
  }

  public var stationResults: [ExerciseResult] {
    results.filter { $0.kind == .station }
  }
}
