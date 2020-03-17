//
//  AudioPlayer.swift
//  SleepBooster
//
//  Created by Nikita Pankiv on 16.03.2020.
//  Copyright © 2020 nikpankiv. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    private var player: AVAudioPlayer
    
    init?(file: String) {
        guard let filePath = Bundle.main.path(forResource: file, ofType: "wav"), let url = URL(string: filePath), let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        
        self.player = player
        player.prepareToPlay()
    }
    
    func play() {
        player.play(atTime: 0.0)
    }
    
    func stop() {
        player.stop()
    }
}
