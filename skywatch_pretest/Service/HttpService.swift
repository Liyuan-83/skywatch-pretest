//
//  HttpService.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation
enum HttpServiceError: Error {
    case httpError, decodeError
}

class HttpService: ServiceProtocol {
    static var shared: ServiceProtocol {
        return HttpService()
    }
    
    func fetchData<ResModel: ModelProtocol>(_ para: [String: Any], _ type: ResModel.Type) async -> Result<ResModel.ModelType, Error> {
        var paraDic = para
        let partStr = ResModel.partArr.map({ $0.rawValue }).joined(separator: ",")
        paraDic["part"] = partStr
        do {
            let data = try await sendHttpRequest(ResModel.apiType, paraDic)
            guard let model = try ResModel(with: data) as? ResModel.ModelType else { throw HttpServiceError.decodeError }
            return .success(model)
        } catch {
            return .failure(error)
        }
    }
}

extension HttpService {
    internal enum HttpError: Error {
        case urlInitFail, notFound, decodeError
    }
    
    internal func sendHttpRequest(_ type: ApiType, _ para: [String: Any]) async throws -> YoutubeApiResponse {
        var urlStr = base_url + type.rawValue + "?key=" + API_KEY
        para.forEach { key, value in
            urlStr += "&\(key)=\(value)"
        }
        guard let url = URL(string: urlStr) else { throw HttpError.urlInitFail }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw HttpError.notFound
                }
        let decoder = JSONDecoder()
        let res = try decoder.decode(YoutubeApiResponse.self, from: data)
        return res
    }
}
