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
        return _forTest ? MockHttpManager<ChannelInfo>() : HttpManager<ChannelInfo>()
    }
    
    private var _playListService : any ServiceProtocol<PlayList>{
        return _forTest ? MockHttpManager<PlayList>() : HttpManager<PlayList>()
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
        let channelRes = await _channelService.fetchData(["id":YOASOBI_Channel_ID], [.contentDetails, .snippet, .statistics])
        
        switch channelRes{
        case .success(let info):
            _channelInfo = info
            break
        case .failure(_):
            return false
        }
        
        guard let playListID = _channelInfo?.uploadID else { return false }
        let playListRes = await _playListService.fetchData(["playlistId":playListID,
                                                                   "maxResults":30], [.snippet])
        switch playListRes{
        case .success(let playList):
            guard let list = playList.list else { return false }
            _allList = list
            _nextPageToken = playList.nextPageToken
            break
        case .failure(_):
            return false
        }
        //儲存至本地
        saveToLocal()
        return true
    }
    
    ///載入下一頁的資料
    mutating func loadNextPage() async -> NextPageStatus {
        guard let id = _channelInfo?.uploadID,
              let token = _nextPageToken else { return .noMoreData }
        
        let res = await _playListService.fetchData(["playlistId":id,
                                                    "maxResults":20,
                                                    "pageToken":token], [.snippet])
        switch res{
        case .success(let nextPageList):
            guard let list = nextPageList.list else { return .fail }
            _nextPageToken = nextPageList.nextPageToken
            _allList += list
            return .success
        case .failure(_):
            return .fail
        }
    }
}
