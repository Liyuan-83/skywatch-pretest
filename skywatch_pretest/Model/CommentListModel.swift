//
//  CommentListModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/28.
//

import Foundation

struct CommentThreadList : Codable{
    var videoID : String?
    var list : [CommentThread]?
    var nextPageToken : String?
    init(with res: YoutubeApiResponse) throws {
        guard res.kind == .commentThread else { throw DecodeError.KindNotMatch }
        self.videoID = res.items.first?.snippet?.videoID
        self.nextPageToken = res.nextPageToken
        var arr:[CommentThread] = []
        for item in res.items{
            guard let commentThread = try CommentThread(with: item) else { throw DecodeError.CommentThreadFail }
            arr.append(commentThread)
        }
        self.list = arr
    }
}

protocol CommantProtocol : Codable {
    var authorName : String { get set }
    var content : String { get set }
    var createDate : Date { get set }
    var thumbnail : URL? { get set }
    var likeCount : Int { get set }
}

struct CommentThread : CommantProtocol{
    var authorName: String
    var content: String
    var createDate: Date
    var thumbnail: URL?
    var likeCount: Int = 0
    
    var threadID : String?
    ///這個好像跟實際拿得到的留言數有差異
    var subCommentCount : Int = 0
    var subComments : [CommandInfo] = []
    
    init?(with item:Item) throws{
        guard let snippet = item.snippet?.topLevelComment?.snippet else { throw DecodeError.CommentThreadFail }
        //留言基本參數
        self.authorName = snippet.authorDisplayName
        self.content = snippet.textOriginal
        self.thumbnail = URL(string:snippet.authorProfileImageURL)
        self.likeCount = snippet.likeCount
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:snippet.publishedAt)!
        self.createDate = date
        //留言串參數
        self.threadID = item.id
        self.subCommentCount = item.snippet?.totalReplyCount ?? 0
        guard let comments = item.replies?.comments else { return }
        var commentArr : [CommandInfo] = []
        for commant in comments{
            commentArr.append(CommandInfo(with: commant))
        }
        subComments = commentArr
    }
}

struct CommandInfo : CommantProtocol{
    var authorName : String
    var content : String
    var createDate : Date
    var thumbnail : URL?
    var likeCount : Int
    
    init(with comment:Comment){
        self.authorName = comment.snippet.authorDisplayName
        self.content = comment.snippet.textOriginal
        self.thumbnail = URL(string:comment.snippet.authorProfileImageURL)
        self.likeCount = comment.snippet.likeCount
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:comment.snippet.publishedAt)!
        self.createDate = date
    }
}
