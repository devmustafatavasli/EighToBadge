// RecordSessionUseCase.swift
// EighToBadgeCore
//
// Use case for recording a completed workout session with all exercise results
// and heart rate metrics.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation

public struct RecordSessionUseCase {
  private let sessionRepository: any WorkoutSessionRepositoryProtocol

  public init(sessionRepository: any WorkoutSessionRepositoryProtocol) {
    self.sessionRepository = sessionRepository
  }

  public func execute(
    templateName: String,
    isStandardHyrox: Bool,
    results: [ExerciseResult]
  ) async throws -> WorkoutSession {
    guard !results.isEmpty else {
      throw EighToBadgeError.invalidExercise
    }

    let totalDuration = results.reduce(0) { $0 + $1.duration }

    let session = WorkoutSession(
      templateName: templateName,
      isStandardHyrox: isStandardHyrox,
      totalDuration: totalDuration,
      results: results
    )

    try await sessionRepository.create(session)
    return session
  }
}
