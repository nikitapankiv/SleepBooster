//
//  SleepPresenter.swift
//  SleepBooster
//
//  Created by Nikita Pankiv on 16.03.2020.
//  Copyright © 2020 nikpankiv. All rights reserved.
//

import Foundation
import UserNotifications

enum SleepState {
    case idle
    case playing
    case recording
    case paused
    case alarm
}

protocol SleepView: class {
    func set(state: SleepState)
    func alarmed()
}

protocol SleepPresenter {
    func viewDidLoad()
    
    func sleepTimerSelected(minutes: Int)
    func alarmTimeSelected(time: Date)
    
    var sleepTimerIntervals: [Int] { get }
    
    func actionButtonPressed()
}

class SleepPresenterImplementation {
    
    // MARK: - UI
    private var state: SleepState = .idle {
        didSet { view?.set(state: state) }
    }
    
    let sleepTimerIntervals = [1, 5, 10, 15, 20]
    
    
    // MARK: - Private
    private var alarmTime: Date?
    private var sleepTimerDuration: TimeInterval = 0

    // MARK: - Audio Recording
    private lazy var audioRecorder: AudioRecorder = { AudioRecorderImplementation(delegate: self) }()
    
    // MARK: - Sleep Timer
    private let sleepTimerPlayer = AudioPlayer(file: "nature")
    private var sleepTimer: Timer?
    
    // MARK: - Alarm Player
    private let alarmPlayer = AudioPlayer(file: "alarm")

    // MARK: - Injections
    private weak var view: SleepView?
    
    // MARK: - LifeCycle
    init(view: SleepView) {
        self.view = view
    }
}

// MARK: - SleepPresenterInput
extension SleepPresenterImplementation: SleepPresenter {
    func viewDidLoad() {
        
    }

    /// When passed 0 - the timer is turned off
    func sleepTimerSelected(minutes: Int) {
        if minutes == 0 {
            sleepTimerDuration = 0
        } else {
            sleepTimerDuration = TimeInterval(minutes) * 60
        }
    }
    
    func alarmTimeSelected(time: Date) {
        alarmTime = time
    }
    
    func actionButtonPressed() {
        // Logic based on `state`
    }
}

// MARK: - Sleep Timer
extension SleepPresenterImplementation {
    func startSleepTimer() {
        guard let sleepTimerPlayer = sleepTimerPlayer else {
            return
            // TODO: Handle
        }
        sleepTimerPlayer.play()
        
        sleepTimer = Timer.scheduledTimer(withTimeInterval: sleepTimerDuration, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            // TODO: Extract logic to one method
            self.sleepTimerPlayer?.stop()
            self.audioRecorder.startRecording()
            self.state = .recording
            // Stop playing
            // Start recording
            // Change state
            // Schedule alarm
        })
    }
}

// MARK: - Alarm
extension SleepPresenterImplementation {
    func scheduleAlarm(date: Date) {
        let content = UNNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSince(Date()), repeats: false)
        let alarmEvent = UNNotificationRequest(identifier: "sleepAlarm", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(alarmEvent) { [weak self] error in
            guard let self = self else { return }
            // TODO: Extract to method
            self.state = .alarm
            self.alarmPlayer?.play()
        }
    }
}

// MARK: - AudioRecorderDelegate
extension SleepPresenterImplementation: AudioRecorderDelegate {
    func recordingStarted() {
        
    }
    
    func finishedRecording(isSuccessfully: Bool) {
        
    }
    
    func recordingInterrupted() {
        
    }
}
