//
//  ServiceProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/8.
//

import Foundation

protocol ServiceProtocol<ResModel>{
    associatedtype ResModel: ModelProtocol
    func fetchData(_ para:[String:Any],_ part:[APIPart]) async -> Result<ResModel.ModelType, Error>
}
