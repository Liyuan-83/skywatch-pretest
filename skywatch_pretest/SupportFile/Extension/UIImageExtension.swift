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
    
    func loadThumbnails(_ thumbnail: Thumbnails){
        let width = UIScreen.main.bounds.width
        var urlStr = thumbnail.thumbnailsDefault.url
        //依照解析度判定，螢幕寬度越寬，使用解析度越高的圖片，若最高解析度無圖片，則用次高解析度的
        if width > thumbnail.thumbnailsDefault.width {
            urlStr = thumbnail.medium.url
        }
        if width > thumbnail.medium.width {
            urlStr = thumbnail.high.url
        }
        if width > thumbnail.high.width,
           let standard = thumbnail.standard {
            urlStr = standard.url
        }
        if let standard = thumbnail.standard,
           width > standard.width,
           let maxres = thumbnail.maxres {
            urlStr = maxres.url
        }
        guard let url = URL(string: urlStr) else { return }
        print(urlStr)
        load(url: url)
    }
}
