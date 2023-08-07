//
//  ConstParameter.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

let YOASOBI_Channel_ID = "UCvpredjG93ifbCP1Y77JyFA"
var ENCRYPTION_KEY : String{
    return Bundle.main.infoDictionary?["Encryption Key"] as! String
}

var API_KEY : String{
    let encryptionKeyString = Bundle.main.infoDictionary?["API Key Encrypted"] as! String
    return (try? encryptionKeyString.decryptAPIKey()) ?? ""
}

let base_url = "https://www.googleapis.com/youtube/v3/"

enum DecodeError : Error{
    case KindNotMatch, CommentThreadFail, CommentFail
}

enum NextPageStatus {
    case success,fail,noMoreData
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

