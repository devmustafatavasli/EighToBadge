// WorkoutTemplateRepository.swift
// EighToBadgeCore
//
// Repository for managing workout template persistence and retrieval.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftData

public protocol WorkoutTemplateRepositoryProtocol {
  func create(_ template: WorkoutTemplate) async throws
  func fetch(id: UUID) async throws -> WorkoutTemplate?
  func fetchAll() async throws -> [WorkoutTemplate]
  func update(_ template: WorkoutTemplate) async throws
  func delete(_ template: WorkoutTemplate) async throws
}

public final class WorkoutTemplateRepository: WorkoutTemplateRepositoryProtocol {
  private let modelContext: ModelContext

  public init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  public func create(_ template: WorkoutTemplate) async throws {
    modelContext.insert(template)
    try modelContext.save()
  }

  public func fetch(id: UUID) async throws -> WorkoutTemplate? {
    let predicate = #Predicate<WorkoutTemplate> { $0.id == id }
    let descriptor = FetchDescriptor(predicate: predicate)
    return try modelContext.fetch(descriptor).first
  }

  public func fetchAll() async throws -> [WorkoutTemplate] {
    let descriptor = FetchDescriptor<WorkoutTemplate>()
    return try modelContext.fetch(descriptor)
  }

  public func update(_ template: WorkoutTemplate) async throws {
    try modelContext.save()
  }

  public func delete(_ template: WorkoutTemplate) async throws {
    modelContext.delete(template)
    try modelContext.save()
  }
}
