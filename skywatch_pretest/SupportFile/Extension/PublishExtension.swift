//
//  PublishExtension.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/23.
//

import Foundation
import Combine

extension Publisher where Self.Failure == Never {
    func sink(receiveValue: @escaping ((Self.Output) async -> Void)) -> AnyCancellable {
        sink { value in
            Task {
                await receiveValue(value)
            }
        }
    }
}
