//
//  UserDefaultExtension.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/26.
//

import Foundation

extension UserDefaults{
    static func saveToStandard(_ obj:Codable, _ key:String) -> Bool{
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(obj) else { return false }
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
        return true
    }
    
    static func getFromStandard<T:Codable>( _ obj:inout T, _ key:String) -> Bool{
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: key) ,
              let readObj = try? decoder.decode(T.self, from: data) else { return false }
        obj = readObj
        return true
    }
    
    static func removeFromStandard(_ key:String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
