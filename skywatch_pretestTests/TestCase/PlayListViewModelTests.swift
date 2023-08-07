//
//  PlayListViewModelTests.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/27.
//

import XCTest
@testable import skywatch_pretest

final class PlayListViewModelTests: XCTestCase {
    var viewmodel = PlayListViewModel()
    override func setUp() async throws {
        print("-----setUp-----")
        //本地端讀值
        guard !viewmodel.loadFromLocal() else { return }
        guard await viewmodel.fetchData() else { throw TestError.InitFail }
    }
    
    func testInitViewModel() async throws {
        //確認必要的頻道資訊
        XCTAssertNotNil(viewmodel.channelInfo)
        XCTAssertNotNil(viewmodel.channelInfo?.name)
        XCTAssertNotNil(viewmodel.channelInfo?.uploadID)
        XCTAssertNotNil(viewmodel.channelInfo?.thumbnails)
        
        //確認必要的列表資訊
        XCTAssertTrue(viewmodel.showList.count >= 30)
        for videoInfo in viewmodel.showList{
            XCTAssertNotNil(videoInfo.id)
            XCTAssertNotNil(videoInfo.name)
            XCTAssertNotNil(videoInfo.thumbnails)
            XCTAssertNotNil(videoInfo.createDate)
        }
    }
    
    func testSearchKeyword() async throws {
        let keyword = "Music Video"
        viewmodel.searchKeyword = keyword
        for videoInfo in viewmodel.showList{
            XCTAssertNotNil(videoInfo.name)
            XCTAssertTrue(videoInfo.name!.contains(keyword))
        }
    }
    
    func testLoadNextPage() async throws {
        let listCount = viewmodel.showList.count
        let status = await viewmodel.loadNextPage()
        XCTAssertTrue(status == .success)
        XCTAssertTrue(viewmodel.showList.count == listCount + 20)
        for videoInfo in viewmodel.showList{
            XCTAssertNotNil(videoInfo.id)
            XCTAssertNotNil(videoInfo.name)
            XCTAssertNotNil(videoInfo.thumbnails)
            XCTAssertNotNil(videoInfo.createDate)
        }
    }
    
    func testClearViewModelFromLocal() async throws {
        viewmodel.clearFromLocal()
        XCTAssertFalse(viewmodel.loadFromLocal())
    }
}
