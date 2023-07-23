//
//  Constent.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

let API_KEY = "AIzaSyAh14rDuPfiszCq0Dnn8VYia1oML4pd0UA"
let base_url = "https://www.googleapis.com/youtube/v3/"

enum Api_type: String{
    case playListItem = "playlistItems"
    case channals = "channels"
    case videos = "videos"
}

enum Kind: String, Codable {
    case youtubeChannel = "youtube#channel"
    case youtubePlaylistItem = "youtube#playlistItem"
    case youtubeVideo = "youtube#video"
}

enum ResposeKind: String, Codable{
    case channel = "youtube#channelListResponse"
    case playItem = "youtube#playlistItemListResponse"
    case videoList = "youtube#videoListResponse"
}

