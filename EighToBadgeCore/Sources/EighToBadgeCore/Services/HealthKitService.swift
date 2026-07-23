// HealthKitService.swift
// EighToBadgeCore
//
// Service for reading heart rate data from HealthKit during active workouts.
// All reads are from the device's local HealthKit store.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import HealthKit

public actor HealthKitService {
  private let healthStore = HKHealthStore()
  private(set) var isAvailable = HKHealthStore.isHealthDataAvailable()
  private(set) var hasHeartRatePermission = false

  public init() {}

  public func requestHeartRatePermission() async throws {
    guard isAvailable else {
      throw EighToBadgeError.healthKitNotAvailable
    }

    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let typesToShare: Set<HKSampleType> = []
    let typesToRead: Set<HKObjectType> = [heartRateType]

    do {
      try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
      let status = healthStore.authorizationStatus(for: heartRateType)
      hasHeartRatePermission = (status == .sharingAuthorized)
    } catch {
      throw EighToBadgeError.healthKitAccessDenied
    }
  }

  public func getCurrentHeartRate() async throws -> Int? {
    guard isAvailable else {
      return nil
    }

    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let query = HKSampleQuery(
      sampleType: heartRateType,
      predicate: HKQuery.predicateForSamples(
        withStart: Date(timeIntervalSinceNow: -60),
        end: Date()
      ),
      limit: HKObjectQueryNoLimit,
      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
    ) { _, samples, _ in
      // This is handled via completion handler in the background
    }

    return await withCheckedThrowingContinuation { continuation in
      var completed = false

      let query = HKSampleQuery(
        sampleType: heartRateType,
        predicate: HKQuery.predicateForSamples(
          withStart: Date(timeIntervalSinceNow: -10),
          end: Date()
        ),
        limit: 1,
        sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
      ) { _, samples, error in
        guard !completed else { return }
        completed = true

        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let sample = samples?.first as? HKQuantitySample else {
          continuation.resume(returning: nil)
          return
        }

        let heartRateBPM = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
        continuation.resume(returning: heartRateBPM)
      }

      healthStore.execute(query)
    }
  }

  public func startObservingHeartRate(interval: TimeInterval = 1.0) {
    // For live updates during workout, apps typically poll getCurrentHeartRate()
    // at regular intervals rather than use live queries (which are more resource-intensive)
  }
}
