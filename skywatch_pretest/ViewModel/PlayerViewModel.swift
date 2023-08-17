//
//  PlayerViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/27.
//

import Foundation
import YouTubeiOSPlayerHelper
import Combine

struct PlayerViewModel<ServiceType: ServiceProtocol>: ViewModelProtocol {
    private var _channelInfo: ChannelInfo
    private var _videoInfo: VideoInfo
    private var _commentList: CommentThreadList
    internal var _forTest: Bool = false
    
    var playstatus: YTPlayerState = .unknown
    var currentTime: Float = 0
    
    internal var _service: ServiceType {
        return ServiceType.shared as! ServiceType
    }
    
    init() {
        _channelInfo = ChannelInfo()
        _videoInfo = VideoInfo()
        _commentList = CommentThreadList()
    }
    
    init(channelInfo: ChannelInfo, videoInfo: VideoInfo, _ isForTest: Bool = false) {
        _channelInfo = channelInfo
        _videoInfo = videoInfo
        _commentList = CommentThreadList()
        _forTest = isForTest
    }
    
    var channelInfo: ChannelInfo {
        return _channelInfo
    }
    
    var videoID: String {
        return _videoInfo.id
    }
    
    var videoName: String {
        return _videoInfo.name
    }
    
    var videoCreatDate: Date {
        return _videoInfo.createDate
    }
    
    var videoDescription: String {
        return _videoInfo.description
    }
    
    var comments: [CommentThread] {
        return _commentList.list
    }
    
    mutating func fetchData() async -> Bool {
        let id = _videoInfo.id
        guard let comments = await CommentThreadList.fetchDataFrom(_service, .firstPage(id: id)) else { return false }
        _commentList = comments
        // 儲存至本地
        saveToLocal()
        return true
    }
    
    mutating func loadMoreComment() async -> NextPageStatus {
        let id = _videoInfo.id
        let token = _commentList.nextPageToken
        guard !token.isEmpty else { return .noMoreData }
        guard let nextPagecomments = await CommentThreadList.fetchDataFrom(_service, .nextPage(id: id, token: token)) else { return .fail }
        _commentList.nextPageToken = nextPagecomments.nextPageToken
        _commentList.list += nextPagecomments.list
        // 儲存至本地
        saveToLocal()
        return .success
    }
}

extension YTPlayerState: Codable {
    
}
