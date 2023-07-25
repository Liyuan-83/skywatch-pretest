//
//  DateExtension.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/25.
//

import Foundation

extension Date{
    func stringWith(_ format:String) -> String{
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: self)
    }
}
