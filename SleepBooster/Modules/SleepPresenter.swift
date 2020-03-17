//
//  SleepPresenter.swift
//  SleepBooster
//
//  Created by Nikita Pankiv on 16.03.2020.
//  Copyright © 2020 nikpankiv. All rights reserved.
//

import Foundation

enum SleepState {
    case idle
    case playing
    case recording
    case paused
    case alarm
}

protocol SleepView: class {
    func set(state: SleepState)
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

    
    //MARK: Injections
    private weak var view: SleepView?
    
    //MARK: LifeCycle
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
        
    }
}
