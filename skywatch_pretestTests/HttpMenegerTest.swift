//
//  HttpMenegerTest.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/22.
//

import XCTest
@testable import skywatch_pretest

final class HttpMenegerTest: XCTestCase {

    func testToGetChannelInfo() async throws {
        let meneger = HttpMeneger()
        let channelInfo = try await meneger.getChannelInfo("UCvpredjG93ifbCP1Y77JyFA")
        //確保要顯示的內容有名字、描述、uploadID、縮圖
        XCTAssertNotNil(channelInfo.name)
        XCTAssertNotNil(channelInfo.description)
        XCTAssertNotNil(channelInfo.uploadID)
        XCTAssertNotNil(channelInfo.thumbnails)
    }
    
    func testToGetPlayList() async throws {
        let meneger = HttpMeneger()
        let channelInfo = try await meneger.getChannelInfo("UCvpredjG93ifbCP1Y77JyFA")
        
        XCTAssertNotNil(channelInfo.uploadID)
        guard let listID = channelInfo.uploadID else { return }
        
        let playList = try await meneger.getPlayList(listID)
        //確保列表有值且數量為30
        XCTAssertNotNil(playList.list)
        XCTAssertEqual(playList.list?.count, 30)
        //確保可以拿到下一頁
        XCTAssertNotNil(playList.nextPageToken)
        guard let list = playList.list,
              let nextPageToken = playList.nextPageToken else { return }
        //確保列表內容不為空
        for item in list{
            XCTAssertNotNil(item.id)
            XCTAssertNotNil(item.createDate)
            XCTAssertNotNil(item.description)
            XCTAssertNotNil(item.name)
            XCTAssertNotNil(item.thumbnails)
            print(item.name!)
        }
        print("--------------------------------")
        let nextList = try await meneger.getPlayList(listID, 20, nextPageToken)
        //確保列表有值且數量為20
        XCTAssertNotNil(nextList.list)
        XCTAssertEqual(nextList.list?.count, 20)
        //確保可以拿到下一頁
        XCTAssertNotNil(nextList.nextPageToken)
        
        guard let list = nextList.list else { return }
        //確保列表內容不為空
        for item in list{
            XCTAssertNotNil(item.id)
            XCTAssertNotNil(item.createDate)
            XCTAssertNotNil(item.description)
            XCTAssertNotNil(item.name)
            XCTAssertNotNil(item.thumbnails)
            print(item.name!)
        }
    }
}
