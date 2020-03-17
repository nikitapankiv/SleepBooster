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
    
    var info: String {
        switch self {
        case .alarm: return "Alarm"
        case .idle: return "Idle"
        case .paused: return "Paused"
        case .playing: return "Playing"
        case .recording: return "Recording"
        }
    }
}

protocol SleepView: class {
    func set(state: SleepState)
    func alarmed()
    func updateUI()
}

protocol SleepPresenter {
    func viewDidLoad()
    
    var sleepTimerInfo: String { get }
    var alarmTimeInfo: String { get }
    var stateInfo: String { get }
    
    func sleepTimerSelected(minutes: Int)
    func alarmTimeSelected(time: Date)
    
    var sleepTimerIntervals: [Int] { get }
    
    func actionButtonPressed()
    func stopPressed()
}

class SleepPresenterImplementation {
    
    // MARK: - UI
    private var state: SleepState = .idle {
        didSet { view?.set(state: state) }
    }
    
    let sleepTimerIntervals = [1, 5, 10, 15, 20]
    
    var sleepTimerInfo: String {
        sleepTimerDuration == 0 ? "Off" : "\(sleepTimerDuration) min"
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
    var alarmTimeInfo: String {
        if let alarmTime = alarmTime {
            return dateFormatter.string(from: alarmTime)
        } else {
            return "Alarm not set"
        }
    }
    
    var stateInfo: String { state.info }
    
    // MARK: - Private
    private var alarmTime: Date?
    /// In minutes
    private var sleepTimerDuration: Int = 0

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
extension SleepPresenterImplementation {
    func update(state: SleepState) {
        switch state {
        case .alarm:
            alarmPlayer?.play()
            view?.alarmed()
        case .idle:
            alarmPlayer?.stop()
            sleepTimerPlayer?.stop()
        case .paused:
            break
        case .playing:
            break
        case .recording:
            sleepTimerPlayer?.stop()
            guard let alarmTime = alarmTime else { return }
            scheduleAlarm(date: alarmTime)
        }
    }
}

// MARK: - SleepPresenterInput
extension SleepPresenterImplementation: SleepPresenter {
    func viewDidLoad() {
        view?.updateUI()
    }

    /// When passed 0 - the timer is turned off
    func sleepTimerSelected(minutes: Int) {
        sleepTimerDuration = minutes
        view?.updateUI()
    }
    
    func alarmTimeSelected(time: Date) {
        // TODO: Check whether time it is today or tomorrow
        alarmTime = time
        view?.updateUI()
    }
    
    func actionButtonPressed() {
        // Logic based on `state`
        
        guard let alarmTime = alarmTime else { return }
        scheduleAlarm(date: alarmTime)
    }
    
    func stopPressed() {
        state = .idle
        // Stop alarm
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
        
        sleepTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(sleepTimerDuration) * 60, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.audioRecorder.startRecording() // AKA try start
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
        }
    }
}

// MARK: - AudioRecorderDelegate
extension SleepPresenterImplementation: AudioRecorderDelegate {
    func recordingStarted() {
        state = .recording
    }
    
    func finishedRecording(isSuccessfully: Bool) {
        
    }
    
    func recordingInterrupted() {
        
    }
}
