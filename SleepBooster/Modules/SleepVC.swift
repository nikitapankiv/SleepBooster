//
//  ViewController.swift
//  SleepBooster
//
//  Created by Nikita Pankiv on 16.03.2020.
//  Copyright © 2020 nikpankiv. All rights reserved.
//

import UIKit

class SleepVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var timerCountLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    // MARK: Injections
    var presenter: SleepPresenter!
    
    // MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let presenter = SleepPresenterImplementation(view: self)
        
        self.presenter = presenter
        presenter.viewDidLoad()
    }

    // MARK: - UI
    @IBAction func actionPressed(_ sender: UIButton) {
        presenter.actionButtonPressed()
    }
    
    // MARK: - SleepTimer
    
    private func setupSleepTimer() {
        let availableMinutes = presenter.sleepTimerIntervals
        
        let alert = UIAlertController(title: "Sleep Timer", message: nil, preferredStyle: .actionSheet)
        
        var actions = availableMinutes.map { UIAlertAction(title: "\($0) minutes", style: .default) { [weak self] a in
            guard let selectedTimeStr = a.title?.components(separatedBy: " ").first, let selectedMinutes = Int(selectedTimeStr) else {
                return
            }
            self?.presenter.sleepTimerSelected(minutes: selectedMinutes)
            }
        }
        actions.append(.init(title: "off", style: .destructive, handler: { [weak self] _ in
            self?.presenter.sleepTimerSelected(minutes: 0)
        }))
        actions.append(.init(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true) { }
    }
    
    // MARK: - Alarm
    
    private func setupAlarmPicker() {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(alarmTimeSelected(_:)), for: .valueChanged)
        datePicker.datePickerMode = .time
        
        pickerTextField.inputView = datePicker
    }
    
    private func presentAlarm() {
        pickerTextField.becomeFirstResponder()
    }
    
    @objc private func alarmTimeSelected(_ sender: UIDatePicker) {
        presenter.alarmTimeSelected(time: sender.date)
    }
}

// MARK: - SleepPresenterOutput
extension SleepVC: SleepView {
    func set(state: SleepState) {
        
    }
    
    func alarmed() {
        let alert = UIAlertController(title: "Alarm", message: nil, preferredStyle: .alert)
        let stopAction = UIAlertAction(title: "Stop", style: .default) { _ in
            // Stop
        }
        alert.addAction(stopAction)
        present(alert, animated: true) { }
    }
}

