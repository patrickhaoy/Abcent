//
//  ViewController.swift
//  Abcent-Swift
//
//  Created by Patrick Yin on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVKit
import AVFoundation

class FeedVC: UIViewController {
    
    var videos: [Video]! = []
    var selectedVideo: Video!
    @IBOutlet weak var feedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllVideoURLs()
        
        self.navigationItem.title = "Feed"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailVC
        destinationVC.selectedVideo = selectedVideo
    }
}

