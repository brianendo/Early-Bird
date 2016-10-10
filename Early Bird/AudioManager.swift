//
//  AudioManager.swift
//  Early Bird
//
//  Created by Brian Endo on 8/21/16.
//  Copyright © 2016 Early Bird. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    struct Static {
        static var onceToken: Int = 0
        static var instance: AudioManager? = nil
    }
    
    private static var __once: () = {
             Static.instance = AudioManager()
        }()
    
    fileprivate var audioPlayer: AVAudioPlayer?
    
    class var sharedInstance: AudioManager {
        _ = AudioManager.__once
        return Static.instance!
    }
    
    func audioView(_ songname: String,format: String) {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: songname, ofType:format)!), fileTypeHint: AVFileTypeMPEGLayer3)
            audioPlayer!.delegate = self;
            audioPlayer!.play()
        } catch {
            // error
        }
    }
    
    func pause() {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
            }
        }
        
    }
}
