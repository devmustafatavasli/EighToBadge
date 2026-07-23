// CreateWorkoutUseCase.swift
// EighToBadgeCore
//
// Use case for creating a new workout template. Validates input and persists
// the template through the repository.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation

public struct CreateWorkoutUseCase {
  private let templateRepository: any WorkoutTemplateRepositoryProtocol

  public init(templateRepository: any WorkoutTemplateRepositoryProtocol) {
    self.templateRepository = templateRepository
  }

  public func execute(
    name: String,
    exercises: [ExercisePlan],
    isStandardHyrox: Bool = false
  ) async throws -> WorkoutTemplate {
    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
      throw EighToBadgeError.invalidWorkoutTemplate
    }

    guard !exercises.isEmpty else {
      throw EighToBadgeError.invalidExercise
    }

    let template = WorkoutTemplate(
      name: name,
      isStandardHyrox: isStandardHyrox,
      exercises: exercises
    )

    try await templateRepository.create(template)
    return template
  }
}
