//
//  ModelProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/7.
//

import Foundation

protocol RequestType {
}

protocol ModelProtocol: Codable {
    /// 目標解碼類型
    associatedtype ModelType: ModelProtocol
    /// 列舉http request事件
    associatedtype ReqType: RequestType
    init(with res: YoutubeApiResponse) throws
    /// 呼叫Youtube API的類型(主要有Channel, Playlist, CommentThead)
    static var apiType: ApiType { get }
    /// 讀取本地端測試用Json資料的檔名
    static var localResourceName: String { get }
    /// YT回應需含有的部分，詳情請參考Youtube API文件
    static var partArr: [APIPart] { get }
    /// 取得傳參
    static func getRequestParameter(type: ReqType) -> [String: Any]
    /// 透過指定的服務(Http / Mock)取得指定要求(request)的數據，並解碼成指定Model，會依照ModelType的不同設定，自動解碼為指定的物件
    static func fetchDataFrom<Service: ServiceProtocol>(_ service: Service, _ type: ReqType) async -> ModelType?
}

extension ModelProtocol {
    static func fetchDataFrom<Service: ServiceProtocol>(_ service: Service, _ type: ReqType) async -> ModelType? {
        let para = getRequestParameter(type: type)
        // 將使用此Proocol的物件類型輸入
        let status = await service.fetchData(para, Self.self)
        switch status {
        case .success(let res):
            return res
        case .failure(_):
            return nil
        }
    }
}
