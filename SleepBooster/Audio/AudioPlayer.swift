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
        guard let filePath = Bundle.main.path(forResource: file, ofType: "m4a"), let url = URL(string: filePath), let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        
        self.player = player
        player.volume = 1.0
        player.prepareToPlay()
    }
    
    func play(isRepeated: Bool = false) {
        player.numberOfLoops = isRepeated ? -1 : 1
        player.play()
    }
    
    func stop() {
        player.stop()
    }
}
