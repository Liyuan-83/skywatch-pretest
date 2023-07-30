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
    var channelInfo : ChannelInfo
    var videoInfo : VideoInfo
//    var commentList : [String]
}

extension YTPlayerState : Codable{
    
}
