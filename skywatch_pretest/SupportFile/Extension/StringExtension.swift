//
//  StringExtension.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/8/1.
//

import Foundation
import UIKit
import Crypto

extension String {
    /// 為保護使用者的全名直接顯示
    func toProtectPersonalName() -> String {
        var maskedString = String(self.prefix(2))
        if count < 3 {
            return "***"
        } else if count < 7 {
            maskedString = String(self.prefix(1))
            let mask = String(repeating: "*", count: count - 1)
            maskedString.append(mask)
        } else {
            let mask = String(repeating: "*", count: count - 4)
            maskedString.append(mask)
            maskedString.append(contentsOf: self.suffix(2))
        }
        return maskedString
    }

    func decryptAPIKey() throws -> String {
        let encryptedData = Data(base64Encoded: self)!
        let keyData = Data(ENCRYPTION_KEY.utf8)
        
        // 使用AES-256解密
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))
        
        // 將解密後的Data轉換成字串
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        return decryptedString
    }
}
