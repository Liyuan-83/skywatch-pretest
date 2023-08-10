//
//  ModelProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/7.
//

import Foundation

protocol ModelProtocol : Codable {
    associatedtype ModelType: ModelProtocol
    init(with res: YoutubeApiResponse) throws
    ///呼叫Youtube API的類型(主要有Channel, Playlist, CommentThead)
    static var apiType : Api_type { get }
    ///讀取本地端測試用Json資料的檔名
    static var localResourceName : String { get }
    ///依照
    static func fetchDataFrom<Service: ServiceProtocol>(_ service: Service) async ->  ModelType?
    static var paraDic: [String:Any]? { get set }
    static var partArr: [APIPart] { get }
}

extension ModelProtocol{
    static func fetchDataFrom<Service: ServiceProtocol>(_ service: Service) async -> ModelType? {
        assert(paraDic != nil, "需設定傳參")
        guard let para = paraDic else { return nil }
        let status = await service.fetchData(para, partArr)
        paraDic = nil
        switch status{
        case .success(let res):
            return res as? ModelType
        case .failure(_):
            return nil
        }
    }
}
