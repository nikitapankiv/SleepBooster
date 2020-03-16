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
    func recordingInterrupted()
}


class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var recordingSession: AVAudioSession = .sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private weak var delegate:AudioRecorderDelegate?
    
    
    init(delegate: AudioRecorderDelegate) {
        self.delegate = delegate
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                // TODO: Add some logic here
            }
        } catch {
            
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("sleep.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            delegate?.recordingStarted()
        } catch {
            finishRecording(success: false)
        }
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil

        delegate?.finishedRecording(isSuccessfully: success)
    }
    
    // MARK: - Delegate

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    // MARK: - Helpers
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
