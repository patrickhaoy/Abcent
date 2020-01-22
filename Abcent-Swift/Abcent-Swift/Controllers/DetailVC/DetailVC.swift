//
//  DetailView.swift
//  Abcent-Swift
//
//  Created by Patrick Yin on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DetailVC: UIViewController {

    //Record
    //var recordButton: UIButton!
    @IBOutlet weak var unsureWords: UILabel!
    @IBOutlet weak var incorrectWords: UILabel!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var currentAudioPath: URL!
    @IBOutlet weak var recordButton: UIButton!
    var recording = false
    @IBOutlet weak var transcriptText: UILabel!
    @IBOutlet weak var score: UILabel!
    
    //Other
    var selectedVideo: Video!
    var isPlaying = true
    @IBOutlet weak var videoView: VideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "\(selectedVideo.title!)"
        
        self.score.isHidden = true
        transcriptText.text = selectedVideo.transcript
        //recordButton.setImage(UIImage(named: "microphone"), for: .normal)
        videoView.configure(url: selectedVideo.videoURL)
        videoView.play()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        videoView.addGestureRecognizer(tap)
        
        viewDidLoadSetup()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if isPlaying {
            videoView.pause()
        } else {
            videoView.play()
        }
        
        isPlaying = !isPlaying
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        if recording {
            recording = false
            videoView.play()
            videoView.alpha = 1.0
            videoView.isUserInteractionEnabled = true
        } else {
            recording = true
            videoView.pause()
            videoView.alpha = 0.3
            videoView.isUserInteractionEnabled = false
        }
    }
}
