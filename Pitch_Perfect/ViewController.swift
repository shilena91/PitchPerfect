//
//  ViewController.swift
//  Pitch_Perfect
//
//  Created by Hoang on 26.3.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordedLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(recording: false)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        }
        catch {
            print("Record failed!")
        }
    }

    @IBAction func recordPressed(_ sender: UIButton) {
        configureUI(recording: true)
        startRecording()
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        configureUI(recording: false)
        
        audioRecorder.stop()
        try! recordingSession.setActive(false)
    }
    
    func startRecording() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "goToSecondVC", sender: audioRecorder.url)
        }
        else {
            recordedLabel.text = "Record is not successful!"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSecondVC" {
            let secondVC = segue.destination as? SecondViewController
            secondVC?.recordedAudioURL = sender as? URL
        }
    }
        
    func configureUI(recording: Bool) {
        if recording {
            recordButton.isEnabled = false
            recordedLabel.text = "Recording!"
            stopButton.isEnabled = true
        }
        else {
            recordButton.isEnabled = true
            recordedLabel.text = "Tap to Record!"
            stopButton.isEnabled = false
        }
    }
}

