//
//  PlayerViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/27.
//

import Foundation
import YouTubeiOSPlayerHelper

struct PlayerViewModel: ViewModelProtocol {
    private var _channelInfo : ChannelInfo?
    private var _videoInfo : VideoInfo?
    private var _commentList : CommentThreadList?
    
    var playstatus : YTPlayerState = .unknown
    var currentTime : Float = 0
    
    init(){
        
    }
    
    init(channelInfo: ChannelInfo, videoInfo: VideoInfo) {
        _channelInfo = channelInfo
        _videoInfo = videoInfo
    }
    
    mutating func fetchData() async -> Bool {
        guard await loadCommentList() else { return false }
        //儲存至本地
        saveToLocal()
        return true
    }
    
    var channelInfo : ChannelInfo? {
        return _channelInfo
    }
    
    var videoID : String? {
        return _videoInfo?.id
    }
    
    var videoName : String? {
        return _videoInfo?.name
    }
    
    var videoCreatDate : Date?{
        return _videoInfo?.createDate
    }
    
    var videoDescription : String?{
        return _videoInfo?.description
    }
    
    var comments : [CommentThread]?{
        return _commentList?.list
    }
    
    mutating func loadMoreComment() async -> NextPageStatus{
        guard let id = _videoInfo?.id,
              let token = _commentList?.nextPageToken else { return .noMoreData }
        
        let res = await HttpManager<CommentThreadList>().fetchData(["videoId":id,
                                                                          "maxResults":20, "order":"relevance",
                                                                    "pageToken":token], [.snippet,.replies])
        switch res{
        case .success(let nextPagecomments):
            guard let list = nextPagecomments.list else { return .fail }
            _commentList?.nextPageToken = nextPagecomments.nextPageToken
            _commentList?.list! += list
            break
        case .failure(_):
            return .fail
        }
        return .success
    }
}

extension PlayerViewModel{
    private mutating func loadCommentList() async -> Bool{
        guard let id = _videoInfo?.id else { return false }
        let res = await HttpManager<CommentThreadList>().fetchData(["videoId":id,
                                                                          "maxResults":30, "order":"relevance"], [.snippet,.replies])
        switch res{
        case .success(let comments):
            _commentList = comments
            break
        case .failure(_):
            return false
        }
        return true
    }
}

extension YTPlayerState : Codable{
    
}
