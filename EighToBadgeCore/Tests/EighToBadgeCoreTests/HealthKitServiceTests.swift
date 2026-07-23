// HealthKitServiceTests.swift
// EighToBadgeCore
//
// Tests for HealthKitService to verify availability and permission handling.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Testing
import Foundation
@testable import EighToBadgeCore

struct HealthKitServiceTests {
  @Test
  func testHealthKitServiceInitialization() async {
    let service = HealthKitService()

    #expect(service.isAvailable == HKHealthStore.isHealthDataAvailable())
    #expect(service.hasHeartRatePermission == false)
  }

  @Test
  func testHealthKitNotAvailableHandling() async throws {
    let service = HealthKitService()

    // On non-Watch devices or if HealthKit isn't available,
    // getCurrentHeartRate() should return nil gracefully
    let hr = try await service.getCurrentHeartRate()
    if !service.isAvailable {
      #expect(hr == nil)
    }
  }
}
