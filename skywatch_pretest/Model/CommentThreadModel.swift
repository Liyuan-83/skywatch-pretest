//
//  CommentThreadModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/28.
//

import Foundation

struct CommentThreadList : ModelProtocol{
    enum CommentThreadRequest : RequestType{
        case firstPage(id:String),
             nextPage(id:String, token:String)
    }
    typealias ModelType = CommentThreadList
    typealias ReqType = CommentThreadRequest
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

//MARK: 固定數值
extension CommentThreadList{
    static var apiType: Api_type{
        return .commentThreads
    }
    
    static var localResourceName: String{
        return "CommentThreadData"
    }
    
    static var partArr: [APIPart] {
        return [.snippet]
    }
    
    static func getRequestParameter(type: CommentThreadRequest) -> [String : Any] {
        switch type{
        case .firstPage(let id):
            return ["videoId":id,
                    "maxResults":30,
                    "order":"relevance"]
        case .nextPage(let id, let token):
            return ["videoId":id,
                    "maxResults":20,
                    "order":"relevance",
                    "pageToken":token]
        }
    }
}

///留言須遵守的Protocol，包含留言串(CommentThread)與回覆(SubComment)
protocol CommentProtocol : Codable {
    var authorName : String { get set }
    var content : String { get set }
    var createDate : Date { get set }
    var thumbnail : URL? { get set }
    var likeCount : Int { get set }
}

///留言串(包含回覆訊息)
struct CommentThread : CommentProtocol{
    var authorName: String
    var content: String
    var createDate: Date
    var thumbnail: URL?
    var likeCount: Int = 0
    
    var threadID : String?
    ///跟實際拿得到的留言數有差異，留言串最多送五筆，超過要另外在呼叫API拿
    var subCommentCount : Int = 0
    var subComments : [SubComment] = []
    
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
        var commentArr : [SubComment] = []
        for comment in comments{
            commentArr.append(SubComment(with: comment))
        }
        subComments = commentArr
    }
}

///回覆訊息
struct SubComment : CommentProtocol{
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
