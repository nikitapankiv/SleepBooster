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
    @IBOutlet weak var actionButton: UIButton!
    
    private var datePicker: UIDatePicker?
    
    // MARK: Injections
    var presenter: SleepPresenter!
    
    // MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let presenter = SleepPresenterImplementation(view: self)
        
        self.presenter = presenter
        presenter.viewDidLoad()
        
        setupAlarmPicker()
        subscribeToEvents()
    }
    
    @objc private func becomeActive() {
        presenter.becomeActive()
    }

    private func subscribeToEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - UI
    @IBAction func actionPressed(_ sender: UIButton) {
        presenter.actionButtonPressed()
    }
    @IBAction func sleepTimerSelectionPressed(_ sender: UITapGestureRecognizer) {
        presentSleepTimerSelection()
    }
    
    @IBAction func alarmSelectionPressed(_ sender: UITapGestureRecognizer) {
        presentAlarmPicker()
    }
    
    // MARK: - SleepTimer
    
    private func presentSleepTimerSelection() {
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
        
        actions.forEach { alert.addAction($0) }
        
        present(alert, animated: true) { }
    }
    
    // MARK: - Alarm

    private func setupAlarmPicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        self.datePicker = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAlarmTimeSelection))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAlarmTimeSelection))
        let alarmLabel = UILabel()
        alarmLabel.text = "Alarm"
        let text = UIBarButtonItem(customView: alarmLabel)
        toolbar.setItems([cancel, spacer, text, spacer, done], animated: true)
        
        pickerTextField.inputView = datePicker
        pickerTextField.inputAccessoryView = toolbar
    }
    
    private func presentAlarmPicker() {
        pickerTextField.becomeFirstResponder()
    }
    
    @objc private func cancelAlarmTimeSelection() {
        view.endEditing(true)
    }
    
    @objc private func doneAlarmTimeSelection() {
        guard let datePicker = datePicker else { return }
        presenter.alarmTimeSelected(time: datePicker.date)
        view.endEditing(true)
    }
}

// MARK: - SleepPresenterOutput
extension SleepVC: SleepView {
    func set(state: SleepState) {
        
    }
    
    func updateUI() {
        timerCountLabel.text = presenter.sleepTimerInfo
        alarmTimeLabel.text = presenter.alarmTimeInfo
        statusLabel.text = presenter.stateInfo
        actionButton.setTitle(presenter.buttonInfo, for: .normal)
    }
    
    func showAlert(text: String, actionText: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let stopAction = UIAlertAction(title: actionText, style: .default) { [weak self] _ in
            self?.presenter.stopPressed()
        }
        alert.addAction(stopAction)
        present(alert, animated: true) { }
    }
}

