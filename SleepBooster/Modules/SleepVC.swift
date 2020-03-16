//
//  ViewController.swift
//  SleepBooster
//
//  Created by Nikita Pankiv on 16.03.2020.
//  Copyright © 2020 nikpankiv. All rights reserved.
//

import UIKit

enum State {
    case idle
    case playing
    case recording
    case paused
    case alarm
}

class SleepVC: UIViewController {
    
    private var alarmTime: Date?
    private var sleepTimerDuration: TimeInterval = 0
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var timerCountLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    // MARK: - UI
    @IBAction func actionPressed(_ sender: UIButton) {
    }
    
    // MARK: - SleepTimer
    
    private func setupSleepTimer() {
        let availableMinutes = [1, 5, 10, 15, 20] // Can be injected
        
        let alert = UIAlertController(title: "Sleep Timer", message: nil, preferredStyle: .actionSheet)
        
        var actions = availableMinutes.map { UIAlertAction(title: "\($0) minutes", style: .default) { [weak self] a in
            guard let selectedTimeStr = a.title?.components(separatedBy: " ").first, let selectedMinutes = Int(selectedTimeStr) else {
                return
            }
            self?.selectedMinutes(minutes: selectedMinutes)
            }
        }
        actions.append(.init(title: "off", style: .destructive, handler: { [weak self] _ in
            self?.selectedMinutes(minutes: 0)
        }))
        actions.append(.init(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true) { }
    }
    
    /// When passed 0 - the timer is turned off
    private func selectedMinutes(minutes: Int) {
        if minutes == 0 {
            sleepTimerDuration = 0
        } else {
            sleepTimerDuration = TimeInterval(minutes) * 60
        }
        
        // TODO: Reload UI
    }
    
    // MARK: - Alarm
    
    private func setupAlarmPicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        
        pickerTextField.inputView = datePicker
    }
    
    private func presentAlarm() {
        
    }

}

