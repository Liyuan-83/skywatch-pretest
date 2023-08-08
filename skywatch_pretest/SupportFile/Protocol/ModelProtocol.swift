//
//  ModelProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/7.
//

import Foundation

protocol ModelProtocol {
    associatedtype ModelType: Codable
    init(with res: YoutubeApiResponse) throws
    static var apiType : Api_type { get }
    static var localResourceName : String { get }
}
