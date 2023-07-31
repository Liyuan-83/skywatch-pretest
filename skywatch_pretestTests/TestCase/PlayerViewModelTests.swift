//
//  PlayerViewModelTests.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/27.
//

import XCTest
@testable import skywatch_pretest

final class PlayerViewModelTests: XCTestCase {
    var viewmodel = PlayerViewModel()
    override func setUp() async throws {
        print("-----setUp-----")
        //本地端讀值
        guard !viewmodel.loadFromLocal() else { return }
        viewmodel.channelInfo = try? await HttpMeneger.shared.getChannelInfo(YOASOBI_Channel_ID)
        guard let playListID = viewmodel.channelInfo?.uploadID,
              let playList = try? await HttpMeneger.shared.getPlayList(playListID),
              let list = playList.list else { throw TestError.InitFail }
        viewmodel.videoInfo = list.first
        viewmodel.saveToLocal()
    }
    
    func testInitViewModel() async throws {
        //確認必要資訊
        XCTAssertNotNil(viewmodel.videoInfo?.id)
        XCTAssertNotNil(viewmodel.channelInfo)
        XCTAssertNotNil(viewmodel.channelInfo?.name)
        XCTAssertNotNil(viewmodel.channelInfo?.thumbnails)
        XCTAssertNotNil(viewmodel.videoInfo?.id)
        XCTAssertNotNil(viewmodel.videoInfo?.name)
        XCTAssertNotNil(viewmodel.videoInfo?.description)
        XCTAssertNotNil(viewmodel.videoInfo?.createDate)
    }
}
