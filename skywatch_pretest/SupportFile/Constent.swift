//
//  Constent.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

let YOASOBI_Channel_ID = "UCvpredjG93ifbCP1Y77JyFA"
let API_KEY = "AIzaSyAh14rDuPfiszCq0Dnn8VYia1oML4pd0UA"
let base_url = "https://www.googleapis.com/youtube/v3/"

enum DecodeError : Error{
    case KindNotMatch, CommentThreadFail, CommentFail
}

enum Api_type: String{
    case playListItem = "playlistItems"
    case channals = "channels"
    case videos = "videos"
    case commentThreads = "commentThreads"
}

enum Kind: String, Codable {
    case youtubeChannel = "youtube#channel"
    case youtubePlaylistItem = "youtube#playlistItem"
    case youtubeVideo = "youtube#video"
    case youtubeCommentThread = "youtube#commentThread"
}

enum ResposeKind: String, Codable{
    case channel = "youtube#channelListResponse"
    case playItem = "youtube#playlistItemListResponse"
    case videoList = "youtube#videoListResponse"
    case commentThread = "youtube#commentThreadListResponse"
}

