//
//  FeedViewCell.swift
//  Abcent-Swift
//
//  Created by Patrick Yin on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//


import UIKit

class FeedTableViewCell: UITableViewCell {
    
    var video: Video? {
        didSet {
            if let video = video {
//                videoLength.text = "Created by: " + video.creator
//                attendeeNumber.text = "\(video.interested.count)"
                videoTitle.text = video.title
                thumbnail.image = video.thumbnail
            }
        }
    }
    
    var thumbnail: UIImageView!
    var videoTitle: UILabel!
    var videoLength: UILabel!
    var attendeeNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCellFrom(size: CGSize) {
        
        thumbnail = UIImageView(frame: CGRect(x: 0, y: 10, width: size.width, height: size.height-30))
        thumbnail.contentMode = .scaleToFill
        thumbnail.layer.cornerRadius = 10
        thumbnail.layer.masksToBounds = true
        thumbnail.alpha = 1.0
        contentView.addSubview(thumbnail)

        
        let imageTint = UIView()
        imageTint.backgroundColor = UIColor(white: 0, alpha: 0.4)
        imageTint.frame = thumbnail.frame
        imageTint.layer.cornerRadius = 10
        contentView.addSubview(imageTint)
        
        videoTitle = UILabel(frame: CGRect(x: 20, y: size.height-70, width: size.width-20, height: 40))
        videoTitle.numberOfLines = 0
        videoTitle.adjustsFontSizeToFitWidth = true
        videoTitle.minimumScaleFactor = 0.3
        videoTitle.font = UIFont(name: "Helvetica-Bold", size: 35)
        videoTitle.textColor = .white
        videoTitle.textAlignment = .left
        contentView.addSubview(videoTitle)
        
        videoLength = UILabel(frame: CGRect(x: 20, y: videoTitle.frame.maxY-70, width: size.width-20, height: 30))
        videoLength.text = ""
        videoLength.numberOfLines = 1
        videoLength.adjustsFontSizeToFitWidth = true
        videoLength.minimumScaleFactor = 0.3
        videoLength.font = UIFont(name: "Helvetica-SemiBold", size: 25)
        videoLength.textColor = .white
        videoLength.textAlignment = .left
        contentView.addSubview(videoLength)
    }

}
