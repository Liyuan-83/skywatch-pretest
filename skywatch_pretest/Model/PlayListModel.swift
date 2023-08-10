//
//  PlayListModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

// MARK: - PlayList
struct PlayList: ModelProtocol {
    enum PlayListRequest : RequestType {
        case firstPage(id:String),
             nextPage(id:String, token:String)
    }
    
    typealias ReqType = PlayListRequest
    typealias ModelType = PlayList
    var list : [VideoInfo]?
    var nextPageToken : String?
    init(with res: YoutubeApiResponse) throws {
        guard res.kind == .playItem else { throw DecodeError.KindNotMatch }
        self.nextPageToken = res.nextPageToken
        var arr:[VideoInfo] = []
        for item in res.items{
            arr.append(VideoInfo(with: item))
        }
        self.list = arr
    }
}

//MARK: 固定數值
extension PlayList{
    static var apiType: Api_type{
        return .playListItem
    }
    
    static var localResourceName: String{
        return "PlayListData"
    }
    
    static var partArr: [APIPart] {
        return [.snippet]
    }
    
    static func getRequestParameter(type: PlayListRequest) -> [String : Any] {
        switch type{
        case .firstPage(let id):
            return ["playlistId":id,
                    "maxResults":30]
        case .nextPage(let id, let token):
            return ["playlistId":id,
                    "maxResults":20,
                    "pageToken":token]
        }
    }
}

// MARK: - VideoInfo
struct VideoInfo: Codable {
    var id : String?
    var createDate : Date?
    var name : String?
    var description : String?
    var thumbnails : Thumbnails?
    
    
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
        if let thumbnails = item.snippet?.thumbnails{
            self.thumbnails = thumbnails
        }
    }
}


