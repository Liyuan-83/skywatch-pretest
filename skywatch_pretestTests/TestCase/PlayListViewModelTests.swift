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
        viewmodel.channelInfo = try? await HttpMeneger.shared.getChannelInfo(YOASOBI_Channel_ID)
        guard let playListID = viewmodel.channelInfo?.uploadID,
              let playList = try? await HttpMeneger.shared.getPlayList(playListID),
              let list = playList.list else { throw TestError.InitFail }
        viewmodel.allList = list
        viewmodel.nextPageToken = playList.nextPageToken
        viewmodel.saveToLocal()
    }
    
    func testInitViewModel() async throws {
        //確認必要的頻道資訊
        XCTAssertNotNil(viewmodel.channelInfo)
        XCTAssertNotNil(viewmodel.channelInfo?.name)
        XCTAssertNotNil(viewmodel.channelInfo?.uploadID)
        XCTAssertNotNil(viewmodel.channelInfo?.thumbnails)
        
        //確認必要的列表資訊
        XCTAssertTrue(viewmodel.allList.count >= 30)
        XCTAssertNotNil(viewmodel.nextPageToken)
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
        let listCount = viewmodel.allList.count
        let token = viewmodel.nextPageToken
        let status = await viewmodel.loadNextPage()
        XCTAssertTrue(status == .success)
        XCTAssertTrue(token != viewmodel.nextPageToken)
        XCTAssertTrue(viewmodel.allList.count == listCount + 20)
        for videoInfo in viewmodel.showList{
            XCTAssertNotNil(videoInfo.id)
            XCTAssertNotNil(videoInfo.name)
            XCTAssertNotNil(videoInfo.thumbnails)
            XCTAssertNotNil(videoInfo.createDate)
        }
    }
}
