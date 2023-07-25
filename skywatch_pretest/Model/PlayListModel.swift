//
//  PlayListModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

// MARK: - PlayList
struct PlayList: Codable {
    var list : [VideoInfo]?
    var nextPageToken : String?
    init(with res: YoutubeApiResponse) {
        self.nextPageToken = res.nextPageToken
        var arr:[VideoInfo] = []
        for item in res.items{
            arr.append(VideoInfo(with: item))
        }
        self.list = arr
    }
}


