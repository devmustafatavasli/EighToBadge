// ActiveWorkoutViewModel.swift
// EighToBadgeWatch
//
// View model managing active workout state, timer updates, heart rate polling,
// and exercise advancement logic.
//
// Created by Mustafa Tavasli on 2026-07-23.
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftUI
import EighToBadgeCore
import Combine

@Observable
final class ActiveWorkoutViewModel: @unchecked Sendable {
  var workoutState: ActiveWorkoutState
  var currentExerciseStartTime: Date?
  var timerPublisher: Timer.TimerPublisher?
  var hrPollingTimer: Timer?
  var showSummary = false
  var summaryResults: [ExerciseResult] = []

  private let healthKitService: HealthKitService
  private let sessionRepository: any WorkoutSessionRepositoryProtocol
  private var timerSubscription: AnyCancellable?
  private var hrSamples: [Int] = []
  private var maxHRDuringExercise: Int = 0

  init(
    template: WorkoutTemplate,
    healthKitService: HealthKitService,
    sessionRepository: any WorkoutSessionRepositoryProtocol
  ) {
    self.workoutState = ActiveWorkoutState(template: template)
    self.healthKitService = healthKitService
    self.sessionRepository = sessionRepository
  }

  func startWorkout() {
    workoutState.isRunning = true
    currentExerciseStartTime = Date()
    startTimer()
    startHeartRatePolling()
  }

  func pauseWorkout() {
    workoutState.isRunning = false
    timerSubscription?.cancel()
    hrPollingTimer?.invalidate()
  }

  func advanceExercise() {
    if let startTime = currentExerciseStartTime {
      let duration = Date().timeIntervalSince(startTime)
      let avgHR = hrSamples.isEmpty ? 0 : hrSamples.reduce(0, +) / hrSamples.count
      let maxHR = maxHRDuringExercise

      workoutState.recordCurrentExerciseResult(
        duration: duration,
        avgHR: avgHR,
        maxHR: maxHR
      )
    }

    hrSamples.removeAll()
    maxHRDuringExercise = 0
    currentExerciseStartTime = Date()

    if workoutState.isLastExercise {
      finishWorkout()
    } else {
      workoutState.advanceToNextExercise()
    }
  }

  func finishWorkout() {
    pauseWorkout()
    summaryResults = workoutState.results
    showSummary = true
  }

  func saveAndDismiss() async {
    let templateName = workoutState.template.name
    let isStandardHyrox = workoutState.template.isStandardHyrox
    let results = workoutState.results
    let repo = sessionRepository

    do {
      let useCase = RecordSessionUseCase(sessionRepository: repo)
      _ = try await useCase.execute(
        templateName: templateName,
        isStandardHyrox: isStandardHyrox,
        results: results
      )

      showSummary = false
    } catch {
      // Handle error (show alert, etc.)
    }
  }

  private func startTimer() {
    timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
    timerSubscription = timerPublisher?
      .autoconnect()
      .sink { [weak self] _ in
        self?.updateTimer()
      }
  }

  private func updateTimer() {
    if workoutState.isRunning {
      workoutState.elapsedSeconds += 0.1
    }
  }

  private func startHeartRatePolling() {
    hrPollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      Task {
        await self?.pollHeartRate()
      }
    }
  }

  private func pollHeartRate() async {
    do {
      if let hr = try await healthKitService.getCurrentHeartRate() {
        await MainActor.run {
          self.hrSamples.append(hr)
          self.maxHRDuringExercise = max(self.maxHRDuringExercise, hr)
          self.workoutState.currentHeartRate = hr
        }
      }
    } catch {
      // HealthKit read failed, continue without HR
    }
  }
}
