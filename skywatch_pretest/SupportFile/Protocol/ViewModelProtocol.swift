//
//  ViewModelProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/26.
//

import Foundation

protocol ViewModelProtocol : Codable{
    var viewModelName : String { get }
    var data : Data? { get }
    
    func saveToLocal()
    func clearFromLocal()
    mutating func fetchData() async -> Bool
    mutating func loadFromLocal() -> Bool
}

extension ViewModelProtocol{
    var viewModelName : String {
        return String(describing: Self.self)
    }
    
    var data : Data? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return data
    }
    
    func clearFromLocal(){
        UserDefaults.removeFromStandard(viewModelName)
    }
    
    func saveToLocal(){
        _ = UserDefaults.saveToStandard(self, viewModelName)
    }
    
    mutating func loadFromLocal() -> Bool{
        return UserDefaults.getFromStandard(&self, viewModelName)
    }
}
