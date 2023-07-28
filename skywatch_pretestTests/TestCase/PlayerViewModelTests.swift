//
//  PlayerViewModelTests.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/27.
//

import XCTest
@testable import skywatch_pretest

final class PlayerViewModelTests: XCTestCase {
    func testInitViewModel() async throws {
        var plyList = PlayListViewModel()
        XCTAssertTrue(plyList.loadFromLocal())
        var videoInfo = plyList.showList.first
    }
}
