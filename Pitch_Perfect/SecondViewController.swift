//
//  SecondViewController.swift
//  Pitch_Perfect
//
//  Created by Hoang on 26.3.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit
import AVFoundation

class SecondViewController: UIViewController {

    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
        configureUI(.notPlaying)
    }
    
    @IBAction func soundPressed(_ sender: UIButton) {
        switch ButtonType(rawValue: sender.tag) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        default: break
        }
        configureUI(.playing)
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        stopAudio()
        configureUI(.notPlaying)
    }
}
