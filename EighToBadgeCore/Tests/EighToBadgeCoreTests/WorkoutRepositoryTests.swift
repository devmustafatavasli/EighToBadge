// WorkoutRepositoryTests.swift
// EighToBadgeCore
//
// Tests for workout template and session repository implementations.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Testing
import Foundation
@testable import EighToBadgeCore

struct WorkoutRepositoryTests {
  @Test
  func testCreateAndFetchWorkoutTemplate() async throws {
    let container = try ModelContainer(
      for: WorkoutTemplate.self, ExercisePlan.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let repository = WorkoutTemplateRepository(modelContext: context)

    let exercise = ExercisePlan(
      order: 0,
      kind: .run,
      type: .run1km,
      targetValue: 1.0,
      unit: "km"
    )

    let template = WorkoutTemplate(
      name: "My Test Workout",
      exercises: [exercise]
    )

    try await repository.create(template)

    let fetched = try await repository.fetch(id: template.id)
    #expect(fetched?.name == "My Test Workout")
    #expect(fetched?.exerciseCount == 1)
  }

  @Test
  func testFetchAllTemplates() async throws {
    let container = try ModelContainer(
      for: WorkoutTemplate.self, ExercisePlan.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let repository = WorkoutTemplateRepository(modelContext: context)

    let exercise = ExercisePlan(
      order: 0,
      kind: .run,
      type: .run1km,
      targetValue: 1.0,
      unit: "km"
    )

    let template1 = WorkoutTemplate(name: "Test 1", exercises: [exercise])
    let template2 = WorkoutTemplate(name: "Test 2", exercises: [exercise])

    try await repository.create(template1)
    try await repository.create(template2)

    let all = try await repository.fetchAll()
    #expect(all.count == 2)
  }

  @Test
  func testCreateAndFetchWorkoutSession() async throws {
    let container = try ModelContainer(
      for: WorkoutSession.self, ExerciseResult.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let repository = WorkoutSessionRepository(modelContext: context)

    let result = ExerciseResult(
      order: 0,
      name: "Sled Push",
      kind: .station,
      targetValue: 50,
      unit: "m",
      duration: 120,
      avgHeartRate: 150,
      maxHeartRate: 165
    )

    let session = WorkoutSession(
      templateName: "Test Workout",
      totalDuration: 120,
      results: [result]
    )

    try await repository.create(session)

    let fetched = try await repository.fetch(id: session.id)
    #expect(fetched?.templateName == "Test Workout")
    #expect(fetched?.results.count == 1)
  }

  @Test
  func testFetchRecentSessions() async throws {
    let container = try ModelContainer(
      for: WorkoutSession.self, ExerciseResult.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let repository = WorkoutSessionRepository(modelContext: context)

    let result = ExerciseResult(
      order: 0,
      name: "Test",
      kind: .station,
      targetValue: 50,
      unit: "m",
      duration: 120,
      avgHeartRate: 150,
      maxHeartRate: 165
    )

    let session1 = WorkoutSession(
      templateName: "Test 1",
      totalDuration: 120,
      results: [result]
    )
    let session2 = WorkoutSession(
      templateName: "Test 2",
      totalDuration: 120,
      results: [result]
    )

    try await repository.create(session1)
    try await repository.create(session2)

    let recent = try await repository.fetchRecent(limit: 1)
    #expect(recent.count == 1)
  }
}
