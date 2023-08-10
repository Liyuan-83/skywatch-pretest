//
//  PlayListViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/25.
//

import Foundation

struct PlayListViewModel: ViewModelProtocol {
    private var _channelInfo : ChannelInfo?
    private var _allList : [VideoInfo] = []
    private var _nextPageToken : String?
    internal var _forTest : Bool = false
    var searchKeyword : String = ""
    
    init(_ isForTest:Bool = false){
        _forTest = isForTest
    }
    
    private var _channelService : any ServiceProtocol<ChannelInfo>{
        return _forTest ? MockHttpService<ChannelInfo>() : HttpService<ChannelInfo>()
    }
    
    private var _playListService : any ServiceProtocol<PlayList>{
        return _forTest ? MockHttpService<PlayList>() : HttpService<PlayList>()
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
        ChannelInfo.paraDic = ["id":YOASOBI_Channel_ID]
        guard let info = await ChannelInfo.fetchDataFrom(_channelService) else { return false }
        _channelInfo = info
        guard let playListID = _channelInfo?.uploadID else { return false }
        PlayList.paraDic = ["playlistId":playListID,
                            "maxResults":30]
        guard let playList = await PlayList.fetchDataFrom(_playListService),
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
        
        PlayList.paraDic = ["playlistId":id,
                            "maxResults":20,
                            "pageToken":token]
        guard let nextPageList = await PlayList.fetchDataFrom(_playListService),
              let list = nextPageList.list else { return .fail }
        _nextPageToken = nextPageList.nextPageToken
        _allList += list
        return .success
    }
}
