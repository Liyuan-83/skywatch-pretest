//
//  PlayListViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/25.
//

import Foundation

struct PlayListViewModel<ServiceType: ServiceProtocol>: ViewModelProtocol {
    private var _channelInfo: ChannelInfo = ChannelInfo()
    private var _allList: [VideoInfo] = []
    private var _nextPageToken: String = ""
    internal var _forTest: Bool = false
    var searchKeyword: String = ""
    internal var _service: ServiceType {
        return ServiceType.shared as! ServiceType
    }
    
    var channelInfo: ChannelInfo {
        return _channelInfo
    }
    
    var showList: [VideoInfo] {
        return _allList.filter({
            guard !searchKeyword.isEmpty else { return true }
            return $0.name.contains(searchKeyword)
        })
    }
    
    mutating func fetchData() async -> Bool {
        guard let info = await ChannelInfo.fetchDataFrom(_service, .info) else { return false }
        _channelInfo = info
        guard let playList = await PlayList.fetchDataFrom(_service, .firstPage(id: _channelInfo.uploadID)) else { return false }
        
        _allList = playList.list
        _nextPageToken = playList.nextPageToken
        // 儲存至本地
        saveToLocal()
        return true
    }
    
    /// 載入下一頁的資料
    mutating func loadNextPage() async -> NextPageStatus {
        guard !_nextPageToken.isEmpty else { return .noMoreData }
        guard let nextPageList = await PlayList.fetchDataFrom(_service, .nextPage(id: _channelInfo.uploadID, token: _nextPageToken)) else { return .fail }
        _nextPageToken = nextPageList.nextPageToken
        _allList += nextPageList.list
        // 儲存至本地
        saveToLocal()
        return .success
    }
}
