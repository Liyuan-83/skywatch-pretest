//
//  PlayListViewModelTests.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/27.
//

import XCTest
@testable import skywatch_pretest

final class PlayListViewModelTests: XCTestCase {
    func testInitViewModel() async throws {
        var viewmodel = PlayListViewModel()
        viewmodel.channelInfo = try? await HttpMeneger.shared.getChannelInfo(YOASOBI_Channel_ID)
        //確認必要的頻道資訊
        XCTAssertNotNil(viewmodel.channelInfo)
        XCTAssertNotNil(viewmodel.channelInfo?.name)
        XCTAssertNotNil(viewmodel.channelInfo?.uploadID)
        XCTAssertNotNil(viewmodel.channelInfo?.thumbnails)
        guard let playListID = viewmodel.channelInfo?.uploadID,
              let playList = try? await HttpMeneger.shared.getPlayList(playListID),
              let list = playList.list else { return }
        viewmodel.allList = list
        viewmodel.nextPageToken = playList.nextPageToken
        //確認必要的列表資訊
        XCTAssertTrue(viewmodel.allList.count >= 30)
        XCTAssertNotNil(viewmodel.nextPageToken)
        for videoInfo in viewmodel.showList{
            XCTAssertNotNil(videoInfo.id)
            XCTAssertNotNil(videoInfo.name)
            XCTAssertNotNil(videoInfo.thumbnails)
            XCTAssertNotNil(videoInfo.createDate)
        }
        //儲存至本地
        viewmodel.saveToLocal()
    }
    
    func testLoadViewModelFromLoacal() async throws {
        var viewmodel = PlayListViewModel()
        XCTAssertTrue(viewmodel.loadFromLocal())
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
        var viewmodel = PlayListViewModel()
        XCTAssertTrue(viewmodel.loadFromLocal())
        var keyword = "Music Video"
        viewmodel.searchKeyword = keyword
        for videoInfo in viewmodel.showList{
            XCTAssertNotNil(videoInfo.name)
            XCTAssertTrue(videoInfo.name!.contains(keyword))
        }
    }
}
