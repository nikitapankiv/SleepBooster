//
//  AudioRecorder.swift
//  SleepBooster
//
//  Created by Nikita Pankiv on 16.03.2020.
//  Copyright © 2020 nikpankiv. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioRecorderDelegate: class {
    func recordingStarted()
    func finishedRecording(isSuccessfully: Bool)
}

protocol AudioRecorder {
    func start()
    func pause()
    func stop()
}

class AudioRecorderImplementation: NSObject, AVAudioRecorderDelegate, AudioRecorder {
    private var recordingSession: AVAudioSession = .sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private weak var delegate:AudioRecorderDelegate?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return formatter
    }()
    
    init(delegate: AudioRecorderDelegate) {
        self.delegate = delegate
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                // TODO: Add some logic here
            }
        } catch {
            // TODO: Add some logic here
        }
    }
    
    func start() {
        if let audioRecorder = audioRecorder {
            audioRecorder.record() // Resumes
            return
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(dateFormatter.string(from: Date())).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = nil
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        
            delegate?.recordingStarted()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func stop() {
        finishRecording(success: true)
    }
    
    func pause() {
        audioRecorder?.pause()
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil

        delegate?.finishedRecording(isSuccessfully: success)
    }
    
    // MARK: - Delegate

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording(success: flag)
    }
    
    // MARK: - Helpers
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
