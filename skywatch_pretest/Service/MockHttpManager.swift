//
//  MockHttpManager.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/8.
//

import Foundation

class MockHttpManager<ResModel: ModelProtocol> : ServiceProtocol{
    func fetchData(_ para: [String : Any], _ part: [APIPart]) async -> Result<ResModel.ModelType, Error> {
        let fileName = ResModel.localResourceName + (para["pageToken"] == nil ? "" : "_next")
        //讀取本地端資訊
        let decoder = JSONDecoder()
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let res = try? decoder.decode(YoutubeApiResponse.self, from: data),
              let model = try? ResModel(with: res) as? ResModel.ModelType
        else { return .failure(HttpManagerError.decodeError) }
        return .success(model)
    }
}
