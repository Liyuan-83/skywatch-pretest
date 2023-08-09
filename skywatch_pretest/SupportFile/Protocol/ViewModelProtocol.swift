//
//  ViewModelProtocol.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/26.
//

import Foundation

protocol ViewModelProtocol : Codable{
    var viewModelName : String { get }
    var _forTest : Bool { get set }
    
    func saveToLocal()
    func clearFromLocal()
    mutating func fetchData() async -> Bool
    mutating func loadFromLocal() -> Bool
}

extension ViewModelProtocol{
    var viewModelName : String {
        return String(describing: Self.self)
    }
    
    func clearFromLocal(){
        UserDefaults.removeFromStandard(viewModelName)
    }
    
    func saveToLocal(){
        guard !_forTest else { return }
        _ = UserDefaults.saveToStandard(self, viewModelName)
    }
    
    mutating func loadFromLocal() -> Bool{
        guard !_forTest else {
            clearFromLocal()
            return false
        }
        return UserDefaults.getFromStandard(&self, viewModelName)
    }
}
