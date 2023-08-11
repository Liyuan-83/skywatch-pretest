//
//  ServiceProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/8.
//

import Foundation

protocol ServiceProtocol{
    static var shared : ServiceProtocol { get }
    func fetchData<ResModel: ModelProtocol>(_ para:[String:Any],_ part:[APIPart], _ type: ResModel.Type) async -> Result<ResModel.ModelType, Error>
}
