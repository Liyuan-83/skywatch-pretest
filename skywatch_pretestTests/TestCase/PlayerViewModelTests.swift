//
//  PlayerViewModelTests.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/27.
//

import XCTest
@testable import skywatch_pretest

final class PlayerViewModelTests: XCTestCase {
    var viewmodel = PlayerViewModel<MockHttpService>()
    override func setUp() async throws {
        print("-----setUp-----")
        //本地端讀值
        var playListVM = PlayListViewModel<MockHttpService>()
        guard await playListVM.fetchData(),
              let videoInfo = playListVM.showList.first(where: {$0.id == test_vidoeID})
        else { throw TestError.InitFail }
        
        viewmodel = PlayerViewModel(channelInfo: playListVM.channelInfo, videoInfo: videoInfo, true)
        guard await viewmodel.fetchData() else { throw TestError.InitFail }
        //確保每次fetch data都有保存到本地端
        XCTAssertTrue(viewmodel.loadFromLocal())
    }
    
    override func tearDown() async throws {
        //測試結束要把測試用數據清除
        viewmodel.clearFromLocal()
        XCTAssertFalse(viewmodel.loadFromLocal())
    }
    
    func testInitViewModel() async throws {
        //確認必要資訊
        XCTAssertNotEqual(viewmodel.channelInfo.name, "")
        XCTAssertNotNil(viewmodel.channelInfo.thumbnails.thumbnailsDefault)
        XCTAssertNotEqual(viewmodel.videoID, "")
        XCTAssertNotEqual(viewmodel.videoName, "")
        XCTAssertNotEqual(viewmodel.videoDescription, "")
        for comment in viewmodel.comments{
            XCTAssertNotEqual(comment.authorName, "")
            XCTAssertNotEqual(comment.content, "")
        }
    }
    
    func testLoadMoreComments() async throws {
        let count = viewmodel.comments.count
        let status = await viewmodel.loadMoreComment()
        XCTAssertTrue(status == .success)
        XCTAssertTrue(viewmodel.comments.count > count)
        for comment in viewmodel.comments{
            XCTAssertNotEqual(comment.authorName, "")
            XCTAssertNotEqual(comment.content, "")
        }
    }
}
