//
//  ServiceProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/8.
//

import Foundation

protocol ServiceProtocol{
    static var shared : ServiceProtocol { get }
    ///設定Request相關參數(para,part)與要解碼對對象類型，輸出成功或失敗的結果，若成功則夾帶解碼後的物件
    func fetchData<ResModel: ModelProtocol>(_ para:[String:Any],_ part:[APIPart], _ type: ResModel.Type) async -> Result<ResModel.ModelType, Error>
}
