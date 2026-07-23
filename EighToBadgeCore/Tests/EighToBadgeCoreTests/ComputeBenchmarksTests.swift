// ComputeBenchmarksTests.swift
// EighToBadgeCore
//
// Tests for the ComputeBenchmarksUseCase to verify personal best computation
// from workout session history.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Testing
import Foundation
@testable import EighToBadgeCore

struct ComputeBenchmarksTests {
  @Test
  func testComputeBenchmarksReturnsPersonalBests() async throws {
    let container = try ModelContainer(
      for: WorkoutTemplate.self, WorkoutSession.self, ExercisePlan.self, ExerciseResult.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let sessionRepository = WorkoutSessionRepository(modelContext: context)

    let result1 = ExerciseResult(
      order: 0,
      name: "Sled Push",
      kind: .station,
      targetValue: 50,
      unit: "m",
      duration: 120,
      avgHeartRate: 150,
      maxHeartRate: 165
    )

    let result2 = ExerciseResult(
      order: 0,
      name: "Sled Push",
      kind: .station,
      targetValue: 50,
      unit: "m",
      duration: 100,
      avgHeartRate: 155,
      maxHeartRate: 170
    )

    let session1 = WorkoutSession(
      templateName: "Test",
      isStandardHyrox: false,
      totalDuration: 120,
      results: [result1]
    )

    let session2 = WorkoutSession(
      templateName: "Test",
      isStandardHyrox: false,
      totalDuration: 100,
      results: [result2]
    )

    try await sessionRepository.create(session1)
    try await sessionRepository.create(session2)

    let useCase = ComputeBenchmarksUseCase(sessionRepository: sessionRepository)
    let benchmarks = try await useCase.execute()

    #expect(benchmarks.count == 1)
    #expect(benchmarks.first?.exerciseName == "Sled Push")
    #expect(benchmarks.first?.bestTime == 100)
    #expect(benchmarks.first?.timesRecorded == 2)
  }

  @Test
  func testComputeBenchmarksFiltersEmptyHistory() async throws {
    let container = try ModelContainer(
      for: WorkoutTemplate.self, WorkoutSession.self, ExercisePlan.self, ExerciseResult.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let sessionRepository = WorkoutSessionRepository(modelContext: context)
    let useCase = ComputeBenchmarksUseCase(sessionRepository: sessionRepository)

    let benchmarks = try await useCase.execute()

    #expect(benchmarks.isEmpty)
  }

  @Test
  func testComputeBenchmarksFiltersByKind() async throws {
    let container = try ModelContainer(
      for: WorkoutTemplate.self, WorkoutSession.self, ExercisePlan.self, ExerciseResult.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let sessionRepository = WorkoutSessionRepository(modelContext: context)

    let runResult = ExerciseResult(
      order: 0,
      name: "1k Run",
      kind: .run,
      targetValue: 1.0,
      unit: "km",
      duration: 300,
      avgHeartRate: 140,
      maxHeartRate: 155
    )

    let stationResult = ExerciseResult(
      order: 1,
      name: "Sled Push",
      kind: .station,
      targetValue: 50,
      unit: "m",
      duration: 120,
      avgHeartRate: 150,
      maxHeartRate: 165
    )

    let session = WorkoutSession(
      templateName: "Test",
      isStandardHyrox: false,
      totalDuration: 420,
      results: [runResult, stationResult]
    )

    try await sessionRepository.create(session)

    let useCase = ComputeBenchmarksUseCase(sessionRepository: sessionRepository)
    let runBenchmarks = try await useCase.benchmarks(for: .run)
    let stationBenchmarks = try await useCase.benchmarks(for: .station)

    #expect(runBenchmarks.count == 1)
    #expect(runBenchmarks.first?.exerciseName == "1k Run")
    #expect(stationBenchmarks.count == 1)
    #expect(stationBenchmarks.first?.exerciseName == "Sled Push")
  }
}
