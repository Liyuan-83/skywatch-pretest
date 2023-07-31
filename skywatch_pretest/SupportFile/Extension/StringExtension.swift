//
//  StringExtension.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/1.
//

import Foundation
import UIKit

extension String{
    ///為保護使用者的全名直接顯示
    func toProtectPersonalName() -> String{
        var maskedString = String(self.prefix(2))
        if count < 3 {
            return "***"
        }
        else if count < 7{
            maskedString = String(self.prefix(1))
            let mask = String(repeating: "*", count: count - 1)
            maskedString.append(mask)
        }else{
            let mask = String(repeating: "*", count: count - 4)
            maskedString.append(mask)
            maskedString.append(contentsOf: self.suffix(2))
        }
        return maskedString
    }
}
