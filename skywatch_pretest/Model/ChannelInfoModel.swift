//
//  ChannelInfo.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

// MARK: - ChannelInfo
struct ChannelInfo: Codable {
    var name : String?
    var description : String?
    var thumbnails : URL?
    var uploadID : String?
    var videoCount : Int
    var subscriberCount : Int
    var viewCount : Int
    
    init(with res: YoutubeApiResponse) throws {
        guard res.kind == .channel else { throw DecodeError.KindNotMatch }
        self.name = res.items.first?.snippet?.title
        self.description = res.items.first?.snippet?.description
        if let thumbnails = res.items.first?.snippet?.thumbnails{
            let urlStr = thumbnails.standard?.url ?? thumbnails.thumbnailsDefault.url
            self.thumbnails = URL(string: urlStr)
        }
        self.uploadID = res.items.first?.contentDetails?.relatedPlaylists?.uploads
        self.videoCount = Int(res.items.first?.statistics?.videoCount ?? "") ?? 0
        self.subscriberCount = Int(res.items.first?.statistics?.subscriberCount ?? "") ?? 0
        self.viewCount = Int(res.items.first?.statistics?.viewCount ?? "") ?? 0
    }
}



