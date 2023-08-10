//
//  ChannelInfo.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

// MARK: - ChannelInfo
struct ChannelInfo: ModelProtocol {
    typealias ModelType = ChannelInfo
    var name : String?
    var description : String?
    var thumbnails : URL?
    var uploadID : String?
    var videoCount : Int = 0
    var subscriberCount : Int = 0
    var viewCount : Int = 0
    
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
    
    static var paraDic: [String : Any]?
}

//MARK: 固定數值
extension ChannelInfo{
    static var apiType: Api_type{
        return .channals
    }
    
    static var localResourceName: String{
        return "ChannelData"
    }
    
    static var partArr: [APIPart] {
        return [.snippet, .contentDetails]
    }
}



