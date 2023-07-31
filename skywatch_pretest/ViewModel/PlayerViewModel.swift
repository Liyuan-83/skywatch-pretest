//
//  PlayerViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/27.
//

import Foundation
import YouTubeiOSPlayerHelper

struct PlayerViewModel: ViewModelProtocol {
    var playstatus : YTPlayerState = .unknown
    var channelInfo : ChannelInfo?
    var videoInfo : VideoInfo?
    var commentList : CommentThreadList?
    
    mutating func loadCommentList() async -> Bool{
        guard let id = videoInfo?.id,
              let list = try? await HttpMeneger.shared.getCommentThreadList(id) else { return false }
        commentList = list
        return true
    }
    
    mutating func loadMoreComment() async -> NextPageStatus{
        guard let id = videoInfo?.id,
              let token = commentList?.nextPageToken else { return .noMoreData }
        
        guard let nextPagecomment = try? await HttpMeneger.shared.getCommentThreadList(id,20,token),
              let list = nextPagecomment.list,
              commentList?.list != nil else { return .fail }
        commentList?.nextPageToken = nextPagecomment.nextPageToken
        commentList?.list! += list
        return .success
    }
}

extension YTPlayerState : Codable{
    
}
