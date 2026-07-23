// ExerciseResult.swift
// EighToBadgeCore
//
// Model representing the recorded result of a single exercise during a workout session.
// Includes timing and heart rate metrics.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftData

@Model
public final class ExerciseResult: Identifiable, Sendable {
  public var id: UUID
  public var order: Int
  public var name: String
  public var kind: ExerciseKind
  public var targetValue: Double
  public var unit: String
  public var duration: TimeInterval
  public var avgHeartRate: Int
  public var maxHeartRate: Int

  public init(
    id: UUID = UUID(),
    order: Int,
    name: String,
    kind: ExerciseKind,
    targetValue: Double,
    unit: String,
    duration: TimeInterval,
    avgHeartRate: Int,
    maxHeartRate: Int
  ) {
    self.id = id
    self.order = order
    self.name = name
    self.kind = kind
    self.targetValue = targetValue
    self.unit = unit
    self.duration = duration
    self.avgHeartRate = avgHeartRate
    self.maxHeartRate = maxHeartRate
  }

  public var durationFormatted: String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: duration) ?? "0:00"
  }

  public var avgPace: String {
    guard duration > 0, targetValue > 0 else { return "--:--" }
    let paceSeconds = duration / targetValue
    return String(format: "%d:%02d", Int(paceSeconds) / 60, Int(paceSeconds) % 60)
  }
}
