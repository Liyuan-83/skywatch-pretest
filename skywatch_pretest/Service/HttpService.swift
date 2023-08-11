//
//  HttpService.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation
enum HttpServiceError : Error{
    case httpError, decodeError
}

class HttpService : ServiceProtocol{
    static var shared: ServiceProtocol{
        return HttpService()
    }
    
    func fetchData<ResModel: ModelProtocol>(_ para:[String:Any],_ part:[APIPart], _ type: ResModel.Type) async -> Result<ResModel.ModelType, Error> {
        var paraDic = para
        let partStr = part.map({$0.rawValue}).joined(separator: ",")
        paraDic["part"] = partStr
        do{
            let data = try await sendHttpRequest(ResModel.apiType, paraDic)
            guard let model = try ResModel(with: data) as? ResModel.ModelType else { throw HttpServiceError.decodeError }
            return .success(model)
        }catch{
            return .failure(error)
        }
    }
}

extension HttpService{
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
