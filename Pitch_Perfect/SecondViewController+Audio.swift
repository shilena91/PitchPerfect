//
//  SecondViewController+Audio.swift
//  Pitch_Perfect
//
//  Created by Hoang on 26.3.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit
import AVFoundation

extension SecondViewController: AVAudioRecorderDelegate {
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    enum PlayingState {
        case playing, notPlaying
    }
    
    // MARK: Audio Functions
    
    func setupAudio() {
        // initialize recording audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
        }
        catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNote = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNote.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNote.rate = rate
        }
        audioEngine.attach(changeRatePitchNote)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNote, echoNode, reverbNode, audioEngine.outputNode)
        }
        else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNote, echoNode, audioEngine.outputNode)
        }
        else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNote, reverbNode, audioEngine.outputNode)
        }
        else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNote, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                }
                else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(self.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoop.Mode.default)
        }
        
        do {
            try audioEngine.start()
        }
        catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        // play the recording!
        audioPlayerNode.play()
    }
    
    @objc func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: Connect List of Audio Nodes

    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count - 1 {
            audioEngine.connect(nodes[x], to: nodes[x + 1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions

    func configureUI(_ playState: PlayingState) {
        switch playState {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
        slowButton.isEnabled = enabled
        fastButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default))
        present(alert, animated: true)
    }
    
}
