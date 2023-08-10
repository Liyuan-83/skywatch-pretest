//
//  PlayerViewModelTests.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/27.
//

import XCTest
@testable import skywatch_pretest

final class PlayerViewModelTests: XCTestCase {
    var viewmodel = PlayerViewModel(true)
    override func setUp() async throws {
        print("-----setUp-----")
        //本地端讀值
        var playListVM = PlayListViewModel(true)
        guard await playListVM.fetchData(),
              let channelInfo = playListVM.channelInfo,
              let videoInfo = playListVM.showList.first(where: {$0.id == test_vidoeID})
        else { throw TestError.InitFail }
        
        viewmodel = PlayerViewModel(channelInfo: channelInfo, videoInfo: videoInfo, true)
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
        XCTAssertNotNil(viewmodel.channelInfo)
        XCTAssertNotNil(viewmodel.channelInfo?.name)
        XCTAssertNotNil(viewmodel.channelInfo?.thumbnails)
        XCTAssertNotNil(viewmodel.videoID)
        XCTAssertNotNil(viewmodel.videoName)
        XCTAssertNotNil(viewmodel.videoDescription)
        XCTAssertNotNil(viewmodel.videoCreatDate)
        guard let list = viewmodel.comments else { return }
        for comment in list{
            XCTAssertNotNil(comment.thumbnail)
        }
    }
    
    func testLoadMoreComments() async throws {
        guard let count = viewmodel.comments?.count else { throw TestError.InitFail }
        let status = await viewmodel.loadMoreComment()
        XCTAssertTrue(status == .success)
        XCTAssertTrue(viewmodel.comments!.count == count + 20)
        guard let list = viewmodel.comments else { return }
        for comment in list{
            XCTAssertNotNil(comment.thumbnail)
        }
    }
}
