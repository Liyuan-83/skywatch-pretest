//
//  PlayListViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/25.
//

import Foundation

struct PlayListViewModel: ViewModelProtocol {
    var channelInfo : ChannelInfo?
    var allList : [VideoInfo] = []
    var nextPageToken : String?
    var searchKeyword : String = ""
    
    var showList : [VideoInfo] {
        return allList.filter({
            guard !searchKeyword.isEmpty else { return true }
            return $0.name?.contains(searchKeyword) ?? false
        })
    }
    
    ///載入下一頁的資料
    mutating func loadNextPage() async -> NextPageStatus {
        guard let id = channelInfo?.uploadID,
              let token = nextPageToken else { return .noMoreData }
        
        guard let nextPageList = try? await HttpMeneger.shared.getPlayList(id,20,token),
              let list = nextPageList.list else { return .fail }
        nextPageToken = nextPageList.nextPageToken
        allList += list
        return .success
    }
}
