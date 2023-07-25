//
//  PlayListViewModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/25.
//

import Foundation

struct PlayListViewModel: Codable {
    var channelInfo : ChannelInfo?
    var allList : [VideoInfo] = []
    var showList : [VideoInfo] {
        return allList.filter({
            guard !searchKeyword.isEmpty else { return true }
            return $0.name?.contains(searchKeyword) ?? false
        })
    }
    var nextPageToken : String?
    var searchKeyword : String = ""
}
