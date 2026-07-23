// WorkoutSessionRepository.swift
// EighToBadgeCore
//
// Repository for managing workout session persistence and retrieval.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftData

public protocol WorkoutSessionRepositoryProtocol: Sendable {
  func create(_ session: WorkoutSession) async throws
  func fetch(id: UUID) async throws -> WorkoutSession?
  func fetchAll() async throws -> [WorkoutSession]
  func fetchRecent(limit: Int) async throws -> [WorkoutSession]
  func update(_ session: WorkoutSession) async throws
  func delete(_ session: WorkoutSession) async throws
}

public actor WorkoutSessionRepository: WorkoutSessionRepositoryProtocol {
  private let modelContext: ModelContext

  public init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  public func create(_ session: WorkoutSession) async throws {
    modelContext.insert(session)
    try modelContext.save()
  }

  public func fetch(id: UUID) async throws -> WorkoutSession? {
    let predicate = #Predicate<WorkoutSession> { $0.id == id }
    let descriptor = FetchDescriptor(predicate: predicate)
    return try modelContext.fetch(descriptor).first
  }

  public func fetchAll() async throws -> [WorkoutSession] {
    var descriptor = FetchDescriptor<WorkoutSession>()
    descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
    return try modelContext.fetch(descriptor)
  }

  public func fetchRecent(limit: Int) async throws -> [WorkoutSession] {
    var descriptor = FetchDescriptor<WorkoutSession>()
    descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
    descriptor.fetchLimit = limit
    return try modelContext.fetch(descriptor)
  }

  public func update(_ session: WorkoutSession) async throws {
    try modelContext.save()
  }

  public func delete(_ session: WorkoutSession) async throws {
    modelContext.delete(session)
    try modelContext.save()
  }
}
