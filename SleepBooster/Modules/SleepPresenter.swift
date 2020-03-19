//
//  SleepPresenter.swift
//  SleepBooster
//
//  Created by Nikita Pankiv on 16.03.2020.
//  Copyright © 2020 nikpankiv. All rights reserved.
//

import Foundation
import UserNotifications
import AVFoundation // A bit redundant i know

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
    func updateUI()
    func showAlert(text: String, actionText: String)
}

protocol SleepPresenter {
    func viewDidLoad()
    func becomeActive()
    
    var sleepTimerInfo: String { get }
    var alarmTimeInfo: String { get }
    var stateInfo: String { get }
    var buttonInfo: String { get }
    
    func sleepTimerSelected(minutes: Int)
    func alarmTimeSelected(time: Date)
    
    var sleepTimerIntervals: [Int] { get }
    
    func actionButtonPressed()
    func stopPressed()
}

class SleepPresenterImplementation {
    
    // MARK: - UI
    private var state: SleepState = .idle {
        didSet {
            update(state: state)
            view?.set(state: state)
        }
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
    private var alarmTimer: Timer?
    /// In minutes
    private var sleepTimerDuration: Int = 0
    
    private var isRestoreNeeded: Bool = false

    // MARK: - Audio Recording
    private lazy var audioRecorder: AudioRecorder = { AudioRecorderImplementation(delegate: self) }()
    
    // MARK: - Sleep Timer
    private var sleepTimerPlayer: AudioPlayer?
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
            audioRecorder.stop()
            alarmPlayer?.play()
            view?.showAlert(text: "Alarm", actionText: "Stop")
        case .idle:
            alarmPlayer?.stop()
            sleepTimerPlayer?.stop()
        case .paused:
            break
        case .playing:
            break
        case .recording:
            sleepTimerPlayer?.stop()
        }
        
        view?.updateUI()
    }
}

// MARK: - SleepPresenterInput
extension SleepPresenterImplementation: SleepPresenter {
    func viewDidLoad() {
        view?.updateUI()
        
        setupPlayback() // May be redundant
        
        subscribeToEvents()
    }
    
    func becomeActive() {
        if isRestoreNeeded {
            // Try Restore Session
            setupPlayback()
            
            switch state {
            case .playing: sleepTimerPlayer?.play()
            case .recording: audioRecorder.start()
            default: break
            }
            isRestoreNeeded = false
        }
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
    
    // Main logic
    func actionButtonPressed() {
        switch state {
        case .idle:
            guard let alarmTime = alarmTime else {
                view?.showAlert(text: "Select alarm time", actionText: "Ok")
                return
            }
            scheduleAlarm(date: alarmTime)
            
            if sleepTimerDuration == 0 {
                audioRecorder.start()
            } else {
                startSleepTimer()
            }
        case .paused:
            // Detect whether need to restore recording or playing
            if let sleepTimerPlayer = sleepTimerPlayer { // We play sound
                sleepTimerPlayer.play()
                state = .playing
            } else { // We record
                audioRecorder.start()
                state = .recording
            }
        case .playing:
            state = .paused
            sleepTimerPlayer?.pause() // Won't pause the timer, sry
        case .recording:
            state = .paused
            audioRecorder.pause()
        default: break
        }
    }
    
    func stopPressed() {
        state = .idle
        // Stop alarm
    }
    
    var buttonInfo: String {
        switch state {
        case .playing, .recording:
            return "Pause"
        default:
            return "Play"
        }
    }
}

// MARK: - Subscription
extension SleepPresenterImplementation {
    func subscribeToEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(interrupred(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
}

// MARK: - Sleep Timer
extension SleepPresenterImplementation {
    func startSleepTimer() {
        let sleepTimerPlayer = AudioPlayer(file: "nature")
        sleepTimerPlayer?.play(isRepeated: true)
        self.sleepTimerPlayer = sleepTimerPlayer
        
        state = .playing
        
        sleepTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(sleepTimerDuration) * 60, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            
            self.sleepTimerPlayer = nil // Required to know which to resume
            self.audioRecorder.start() // AKA try start
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
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Wake up!"
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
        let timeToFire = timeIntervalToAlarm(alarmDate: date)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeToFire, repeats: false)
        let alarmEvent = UNNotificationRequest(identifier: "sleepAlarm", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(alarmEvent) { _ in  }
        alarmTimer = Timer.scheduledTimer(withTimeInterval: timeToFire, repeats: false, block: { [weak self] _ in
            self?.state = .alarm
        })
    }
    
    private func timeIntervalToAlarm(alarmDate: Date) -> TimeInterval {
        // Extract to another method
        let calendar = Calendar.current
        let rightNow = Date()

        let requiredComponents = Set([Calendar.Component.year, .month, .day, .hour, .minute])
        
        var alarmComponents = calendar.dateComponents(requiredComponents, from: alarmDate)
        if alarmDate < rightNow {
            alarmComponents.day = (alarmComponents.day ?? 0) + 1
        }

        guard let normedAlarmDate = calendar.date(from: alarmComponents) else { return 0 }
        
        return normedAlarmDate.timeIntervalSince(rightNow).rounded()
    }
}

// MARK: - Playback
extension SleepPresenterImplementation {
    func setupPlayback() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch{
            fatalError("playback failed")
        }
    }
    
    // MARK: - Interruprion
    @objc func interrupred(_ notification: Notification) {
        isRestoreNeeded = true
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
