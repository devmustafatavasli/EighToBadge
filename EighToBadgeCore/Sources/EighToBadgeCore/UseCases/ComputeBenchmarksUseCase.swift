// ComputeBenchmarksUseCase.swift
// EighToBadgeCore
//
// Use case for computing personal benchmarks (personal bests) from workout
// session history. Groups by exercise type and returns the fastest time for each.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation

public struct Benchmark: Sendable {
  public let exerciseName: String
  public let kind: ExerciseKind
  public let bestTime: TimeInterval
  public let bestSessionDate: Date
  public let timesRecorded: Int

  public var bestTimeFormatted: String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: bestTime) ?? "0:00"
  }
}

public struct ComputeBenchmarksUseCase {
  private let sessionRepository: any WorkoutSessionRepositoryProtocol

  public init(sessionRepository: any WorkoutSessionRepositoryProtocol) {
    self.sessionRepository = sessionRepository
  }

  public func execute() async throws -> [Benchmark] {
    let sessions = try await sessionRepository.fetchAll()
    var benchmarks: [String: (bestTime: TimeInterval, date: Date, count: Int)] = [:]

    for session in sessions {
      for result in session.results {
        let key = result.name

        if let existing = benchmarks[key] {
          if result.duration < existing.bestTime {
            benchmarks[key] = (result.duration, session.date, existing.count + 1)
          } else {
            benchmarks[key] = (existing.bestTime, existing.date, existing.count + 1)
          }
        } else {
          benchmarks[key] = (result.duration, session.date, 1)
        }
      }
    }

    return benchmarks.map { key, value in
      let firstResult = sessions.flatMap { $0.results }.first { $0.name == key }
      return Benchmark(
        exerciseName: key,
        kind: firstResult?.kind ?? .station,
        bestTime: value.bestTime,
        bestSessionDate: value.date,
        timesRecorded: value.count
      )
    }.sorted { $0.exerciseName < $1.exerciseName }
  }

  public func benchmarks(for kind: ExerciseKind) async throws -> [Benchmark] {
    let all = try await execute()
    return all.filter { $0.kind == kind }
  }
}
