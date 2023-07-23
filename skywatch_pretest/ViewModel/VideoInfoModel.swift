//
//  VideoInfoModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

// MARK: - VideoInfo
struct VideoInfo: Codable {
    var id : String?
    var createDate : Date?
    var name : String?
    var description : String?
    var thumbnails : URL?
    
    
    init(with item:Item){
        self.id = item.snippet?.resourceID?.videoID
        //2023-07-02T13:10:40Z
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:item.snippet?.publishedAt ?? "")!
        self.createDate = date
        
        self.name = item.snippet?.title
        self.description = item.snippet?.description
        if let urlStr = item.snippet?.thumbnails?.thumbnailsDefault?.url{
            self.thumbnails = URL(string: urlStr)
        }
    }
    
    init(with res:YoutubeApiResponse){
        
    }
}

