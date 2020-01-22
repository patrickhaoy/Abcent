//
//  DetailVC-Record.swift
//  Abcent-Swift
//
//  Created by Patrick Yin on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

extension DetailVC {
    func viewDidLoadSetup() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    internal func dismissAlert() { if let vc = self.presentedViewController, vc is UIAlertController { dismiss(animated: false, completion: nil) } }
    
    func loadRecordingUI() {
        //recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
        recordButton.setImage(UIImage(named: "microphone"), for: .normal)
        //recordButton.currentImage = UIImage(named: "microphone")
//        recordButton.setTitle("Tap to Record", for: .normal)
//        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    func convertAudio(_ url: URL, outputURL: URL) {
        var error : OSStatus = noErr
        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile : ExtAudioFileRef? = nil

        var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()

        ExtAudioFileOpenURL(url as CFURL, &sourceFile)

        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))

        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)

        dstFormat.mSampleRate = 44100  //Set sample rate
        dstFormat.mFormatID = kAudioFormatLinearPCM
        dstFormat.mChannelsPerFrame = 1
        dstFormat.mBitsPerChannel = 16
        dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked |
        kAudioFormatFlagIsSignedInteger

        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            kAudioFileWAVEType,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)
        print("Error 1 in convertAudio: \(error.description)")

        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 2 in convertAudio: \(error.description)")

        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 3 in convertAudio: \(error.description)")

        let bufferByteSize : UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: 32768)
        var sourceFrameOffset : ULONG = 0

        while(true){
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames : UInt32 = 0

            if(dstFormat.mBytesPerFrame > 0){
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }

            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            print("Error 4 in convertAudio: \(error.description)")

            if(numFrames == 0){
                error = noErr;
                break;
            }

            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            print("Error 5 in convertAudio: \(error.description)")
        }

        error = ExtAudioFileDispose(destinationFile!)
        print("Error 6 in convertAudio: \(error.description)")
        error = ExtAudioFileDispose(sourceFile!)
        print("Error 7 in convertAudio: \(error.description)")
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        print("audioFilename", audioFilename)
        currentAudioPath = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM), //Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self as? AVAudioRecorderDelegate
            audioRecorder.record()

            recordButton.setImage(UIImage(named: "stop"), for: .normal)
//            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            print("error", error)
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        recordButton.setImage(UIImage(named: "microphone"), for: .normal)
        if success {
//            recordButton.setTitle("Tap to Re-record", for: .normal)
            sendAudioToStorage()
        } else {
//            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func sendAudioToStorage() {
        let audioNode = Storage.storage().reference().child("audio")
        
        //Add Image to Storage
        let localFile = currentAudioPath
        //let audioRef = audioNode.child(selectedVideo.id)
        let audioRef = audioNode.child("\(selectedVideo.id!).wav")
        print("audioRef", String(describing: audioRef))
        
        let newMetadata = StorageMetadata()
//        newMetadata.contentType = "audio/x-wav"
        let uploadTask = audioRef.putFile(from: localFile!, metadata: newMetadata) { metadata, error in
            guard let metadata = metadata else {
              return
            }
            let size = metadata.size
              audioRef.downloadURL { (url, error) in
              guard let downloadURL = url else {
                return
              }
              print("downloadURL", downloadURL)
              // Add to Realtime Database
              let videosNode = Database.database().reference().child("videos")
              let videosRef = videosNode.child(self.selectedVideo.id)
              videosRef.observeSingleEvent(of:. value, with: { snapshot in
                  videosRef.updateChildValues(["audioURL" : downloadURL.absoluteString, "gsAudioURL" : String(describing: audioRef)])
                  print(downloadURL.absoluteString)
                  self.selectedVideo.audioURL = downloadURL.absoluteString
                  self.selectedVideo.gsAudioURL = String(describing: audioRef)
                
                self.selectedVideo.callAPI() { snapshot in
                    print("snapshot", snapshot)
                    let cosine = snapshot["cosine"] as! NSNumber
                    print(cosine)
                    
                    if cosine == 0 {
                        DispatchQueue.main.async(execute: {
                            self.score.text = "What did you say!?"
                            self.score.isHidden = false
                        })
                        return
                    }
                    let incorrect_words = snapshot["incorrect_words"] as! [String]
                    let unsure_words = snapshot["unsure_words"] as! [String]
                    
                    
                    let attributedQuote = NSMutableAttributedString(string: self.selectedVideo.transcript)
                    var index = 0
                    print(self.selectedVideo.transcript.components(separatedBy: " "))
                    for word in self.selectedVideo.transcript.components(separatedBy: " ") {
                        print("word", word)
                        print(index, index+word.count)
                        if incorrect_words.contains(word) {
                            attributedQuote.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: index, length: word.count))
                        } else if unsure_words.contains(word) {
                            attributedQuote.addAttribute(.foregroundColor, value: UIColor.orange, range: NSRange(location: index, length: word.count))
                        } else {
                            attributedQuote.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: index, length: word.count))
                        }
                        index += word.count+1
                    }
                    
//                    let main_string = self.selectedVideo.transcript
                    
//                    for word in incorrect_words {
//                        let range = (main_string as! NSString).range(of: word)
//                        let attribute = NSMutableAttributedString.init(string: main_string!)
//                        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
//                    }
//
//                    for word in unsure_words {
//                        let range = (main_string as! NSString).range(of: word)
//                        let attribute = NSMutableAttributedString.init(string: main_string!)
//                        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange , range: range)
//                    }
                    

                    
                    
                    let cosineString = cosine.stringValue
                    let startIndex = cosineString.index(cosineString.startIndex, offsetBy: 2)
                    let endIndex = cosineString.index(cosineString.startIndex, offsetBy: 4)
                    DispatchQueue.main.async(execute: {
                        self.score.text = cosine.stringValue[startIndex..<endIndex] + "%"
                        self.score.isHidden = false
//                        self.transcriptText.text = main_string
                        self.transcriptText.attributedText = attributedQuote
                    })
                }
              })
            }
        }
    }
}
