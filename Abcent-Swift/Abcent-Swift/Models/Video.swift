//
//  Video.swift
//  Abcent-Swift
//
//  Created by Patrick Yin on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//

import UIKit
import Foundation

class Video {
    let title: String!
    let id: String!
    let thumbnail: UIImage!
    let videoURL: String!
    let transcript: String!
    var audioURL: String!
    var gsAudioURL: String!
    
    init(title: String, id: String, thumbnail: UIImage, videoURL: String, transcript:String!) {
        self.title = title
        self.id = id
        self.thumbnail = thumbnail
        self.videoURL = videoURL
        self.transcript = transcript
    }
    
    func callAPI(completion: @escaping ([String:Any]) -> ()) {
        let headers = [
          "cache-control": "no-cache",
          "Postman-Token": "d5d9c015-4d8b-4e44-acb6-2e8cf40db38a"
        ]
        
        let requestURL = ("https://us-central1-accentreducer.cloudfunctions.net/updated_speech_compare?uri=" + self.gsAudioURL + "&original=" + self.transcript).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        print("requestURL", requestURL)
        guard let url = URL(string: requestURL!) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        print("data", data)
        print("response", response)
        print("error", error)
        guard let dataResponse = data,
                  error == nil else {
                  print(error?.localizedDescription ?? "Response Error")
                  return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                                       dataResponse, options: [])
                let result = jsonResponse
                print("result", result)
                completion(result as! [String : Any]) //Response result
             } catch let parsingError {
                print("Error", parsingError)
                completion(["cosine":0])
           }
        }
        task.resume()
    }
}
