//
//  FeedVC-Firebase.swift
//  Abcent-Swift
//
//  Created by Patrick Yin on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

extension FeedVC {
    func getAllVideoURLs() {
        let videosNode = Database.database().reference().child("videos")
        videosNode.observeSingleEvent(of: .value, with: { (snapshot) in
            let videosDict = snapshot.value as? [String:Any] ?? [:]
            
            for (key, value) in videosDict {
                print("value", value)
                let checkedValue = value as? [String:Any] ?? [:]
                let storage = Storage.storage()
                let thumbnailRef = storage.reference(forURL: checkedValue["thumbnail"] as! String)
                
                thumbnailRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if data == nil {
                        print("data is nil", data)
                    }
                    if let error = error {
                        print(error)
                    } else {
                        let thumbnailImage = UIImage(data: data!)
                        let currentVideo = Video(title: checkedValue["title"] as! String, id: key, thumbnail: thumbnailImage!, videoURL: checkedValue["url"] as! String, transcript: checkedValue["transcript"] as! String)
                        
                        if checkedValue["audioFile"] != nil {
                            currentVideo.audioURL = checkedValue["audioURL"] as! String
                            currentVideo.gsAudioURL = checkedValue["gsAudioURL"] as! String
                        }
                        
                        self.videos.append(currentVideo)
                    }
                    self.feedTableView.reloadData()
                }
            }
        })
    }
}
