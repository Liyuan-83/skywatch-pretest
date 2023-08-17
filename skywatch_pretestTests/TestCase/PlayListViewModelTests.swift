//
//  PlayListViewModelTests.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/27.
//

import XCTest
@testable import skywatch_pretest

final class PlayListViewModelTests: XCTestCase {
    var viewmodel = PlayListViewModel<MockHttpService>()
    override func setUp() async throws {
        print("-----setUp-----")
        // 本地端讀值
        guard await viewmodel.fetchData() else { throw TestError.initFail }
        XCTAssertTrue(viewmodel.loadFromLocal())
    }
    
    override func tearDown() async throws {
        viewmodel.clearFromLocal()
        XCTAssertFalse(viewmodel.loadFromLocal())
    }
    
    func testInitViewModel() async throws {
        // 確認必要的頻道資訊
        XCTAssertNotEqual(viewmodel.channelInfo.name, "")
        XCTAssertNotEqual(viewmodel.channelInfo.uploadID, "")
        XCTAssertNotNil(viewmodel.channelInfo.thumbnails.thumbnailsDefault)
        
        // 確認必要的列表資訊
        XCTAssertTrue(viewmodel.showList.count >= 30)
        for videoInfo in viewmodel.showList {
            XCTAssertNotEqual(videoInfo.id, "")
            XCTAssertNotEqual(videoInfo.name, "")
            XCTAssertNotNil(videoInfo.thumbnails.thumbnailsDefault)
        }
    }
    
    func testSearchKeyword() async throws {
        let keyword = "Music Video"
        viewmodel.searchKeyword = keyword
        for videoInfo in viewmodel.showList {
            XCTAssertNotEqual(videoInfo.name, "")
            XCTAssertTrue(videoInfo.name.contains(keyword))
        }
    }
    
    func testLoadNextPage() async throws {
        let listCount = viewmodel.showList.count
        let status = await viewmodel.loadNextPage()
        XCTAssertTrue(status == .success)
        XCTAssertTrue(viewmodel.showList.count > listCount)
        for videoInfo in viewmodel.showList {
            XCTAssertNotEqual(videoInfo.id, "")
            XCTAssertNotEqual(videoInfo.name, "")
            XCTAssertNotNil(videoInfo.thumbnails.thumbnailsDefault)
        }
    }
}
