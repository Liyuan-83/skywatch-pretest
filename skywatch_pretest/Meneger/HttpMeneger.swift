//
//  HttpMeneger.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation
enum HttpMenegerError : Error{
    case httpError, decodeError
}

class HttpMeneger {
    static var shared = HttpMeneger()
    
    func getChannelInfo(_ channelID:String,_ part: [ChannelsPart] = [.contentDetails, .snippet, .statistics]) async throws -> ChannelInfo{
        let partStr = part.map({$0.rawValue}).joined(separator: ",")
        let data = try await sendHttpRequest(.channals, ["id":channelID, "part":partStr])
        return try ChannelInfo(with: data)
    }
    
    func getPlayList(_ listID:String, _ counts: Int = 30, _ nextPageToken:String? = nil,_ part: [PlayListItemPart] = [.snippet]) async throws -> PlayList{
        let partStr = part.map({$0.rawValue}).joined(separator: ",")
        var para : [String : Any] = ["playlistId":listID, "part":partStr, "maxResults":counts]
        if let token = nextPageToken{
            para["pageToken"] = token
        }
        let data = try await sendHttpRequest(.playListItem, para)
        return try PlayList(with: data)
    }
    
//    func getVideoInfo(_ videoID:String,_ part: [VideosPart] = [.snippet]) async throws -> VideoInfo {
//        let partStr = part.map({$0.rawValue}).joined(separator: ",")
//        var para = ["id":videoID, "part":partStr]
//        let data = try await sendHttpRequest(.videos, para)
//    }
}

extension HttpMeneger{
    internal enum HttpError : Error{
        case UrlInitFail, NotFound, DecodeError
    }
    
    internal func sendHttpRequest(_ type:Api_type,_ para:[String:Any]) async throws -> YoutubeApiResponse {
        var urlStr = base_url + type.rawValue + "?key=" + API_KEY
        para.forEach{ key, value in
            urlStr = urlStr + "&\(key)=\(value)"
        }
        guard let url = URL(string:urlStr) else { throw HttpError.UrlInitFail }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw HttpError.NotFound
                }
        let decoder = JSONDecoder()
        let res = try decoder.decode(YoutubeApiResponse.self, from: data)
        return res
    }
}
