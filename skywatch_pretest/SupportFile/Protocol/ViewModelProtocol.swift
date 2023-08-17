//
//  ViewModelProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/26.
//

import Foundation

protocol ViewModelProtocol: Codable {
    /// 用於決定View Model要使用那個服務(Http Data/Mock Data)來呼叫API
    associatedtype ServiceType: ServiceProtocol
    /// 取得服務
    var _service: ServiceType { get }
    var viewModelName: String { get }
    
    func saveToLocal()
    func clearFromLocal()
    mutating func fetchData() async -> Bool
    mutating func loadFromLocal() -> Bool
}

extension ViewModelProtocol {
    var viewModelName: String {
        return String(describing: Self.self)
    }
    
    func clearFromLocal() {
        UserDefaults.removeFromStandard(viewModelName)
    }
    
    func saveToLocal() {
        _ = UserDefaults.saveToStandard(self, viewModelName)
    }
    
    mutating func loadFromLocal() -> Bool {
        return UserDefaults.getFromStandard(&self, viewModelName)
    }
}
