//
//  FeedVC-TableView.swift
//  Abcent-Swift
//
//  Created by Patrick Yin on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//

import Foundation
import UIKit

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var index = indexPath[1]
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell", for: indexPath) as! FeedTableViewCell
        cell.awakeFromNib()
        let size = CGSize(width: tableView.frame.width, height: height(for: indexPath))
        cell.initCellFrom(size: size)
        cell.selectionStyle = .none
        cell.video = videos[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index = indexPath[1]
        selectedVideo = videos[indexPath.row]
        performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: indexPath)
    }
    
    func height(for index: IndexPath) -> CGFloat {
        return 250
    }
}
