//
//  PlayListViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/25.
//

import Foundation

struct PlayListViewModel<ServiceType: ServiceProtocol>: ViewModelProtocol {
    private var _channelInfo : ChannelInfo?
    private var _allList : [VideoInfo] = []
    private var _nextPageToken : String?
    internal var _forTest : Bool = false
    var searchKeyword : String = ""
    internal var _service : ServiceType{
        return ServiceType.shared as! ServiceType
    }
    
    var channelInfo : ChannelInfo?{
        return _channelInfo
    }
    
    var showList : [VideoInfo] {
        return _allList.filter({
            guard !searchKeyword.isEmpty else { return true }
            return $0.name?.contains(searchKeyword) ?? false
        })
    }
    
    mutating func fetchData() async -> Bool {
        guard let info = await ChannelInfo.fetchDataFrom(_service, .info) else { return false }
        _channelInfo = info
        guard let playListID = _channelInfo?.uploadID else { return false }
        guard let playList = await PlayList.fetchDataFrom(_service, .firstPage(id: playListID)),
              let list = playList.list else { return false }
        
        _allList = list
        _nextPageToken = playList.nextPageToken
        //儲存至本地
        saveToLocal()
        return true
    }
    
    ///載入下一頁的資料
    mutating func loadNextPage() async -> NextPageStatus {
        guard let id = _channelInfo?.uploadID,
              let token = _nextPageToken else { return .noMoreData }
        guard let nextPageList = await PlayList.fetchDataFrom(_service, .nextPage(id: id, token: token)),
              let list = nextPageList.list else { return .fail }
        _nextPageToken = nextPageList.nextPageToken
        _allList += list
        //儲存至本地
        saveToLocal()
        return .success
    }
}
