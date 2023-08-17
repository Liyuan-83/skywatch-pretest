//
//  UIImageExtension.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/24.
//

import Foundation
import UIKit
    
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func loadThumbnails(_ thumbnail: Thumbnails) {
        let cons = constraints.first(where: { $0.firstAttribute == .width })
        let width = cons?.constant ?? UIScreen.main.bounds.width
        var urlStr = thumbnail.thumbnailsDefault?.url
        // 依照解析度判定，螢幕寬度越寬，使用解析度越高的圖片，若最高解析度無圖片，則用次高解析度的
        if let def = thumbnail.thumbnailsDefault,
           width > def.width,
           let medium = thumbnail.medium {
            urlStr = medium.url
        }
        if let medium = thumbnail.medium,
           width > medium.width,
           let high = thumbnail.high {
            urlStr = high.url
        }
        if let high = thumbnail.high,
           width > high.width,
           let standard = thumbnail.standard {
            urlStr = standard.url
        }
        if let standard = thumbnail.standard,
           width > standard.width,
           let maxres = thumbnail.maxres {
            urlStr = maxres.url
        }
        guard let urlStr = urlStr,
              let url = URL(string: urlStr) else { return }
        print(urlStr)
        load(url: url)
    }
}
