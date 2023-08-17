//
//  HttpServiceTest.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/22.
//

import XCTest
@testable import skywatch_pretest

final class HttpServiceTest: XCTestCase {
    var service = HttpService()
    func testToGetChannelInfo() async throws {
        let channelInfo = await ChannelInfo.fetchDataFrom(service, .info)
        XCTAssertNotNil(channelInfo)
        guard let channelInfo = channelInfo else { return }
        // 確保要顯示的內容有名字、描述、uploadID、縮圖
        XCTAssertNotEqual(channelInfo.name, "")
        XCTAssertNotEqual(channelInfo.description, "")
        XCTAssertNotEqual(channelInfo.uploadID, "")
        XCTAssertNotNil(channelInfo.thumbnails.thumbnailsDefault)
    }
    
    func testToGetPlayList() async throws {
        let playList = await PlayList.fetchDataFrom(service, .firstPage(id: test_playListID))
        XCTAssertNotNil(playList)
        guard let playList = playList else { return }
        
        // 確保列表有值
        XCTAssertFalse(playList.list.isEmpty)
        // 確保可以拿到下一頁
        XCTAssertNotEqual(playList.nextPageToken, "")
        // 確保列表內容不為空
        for item in playList.list {
            XCTAssertNotEqual(item.id, "")
            XCTAssertNotEqual(item.name, "")
            XCTAssertNotNil(item.thumbnails.thumbnailsDefault)
        }
        print("--------------------------------")
        let nextList = await PlayList.fetchDataFrom(service, .nextPage(id: test_playListID, token: playList.nextPageToken))
        XCTAssertNotNil(nextList)
        guard let nextList = nextList else { return }
        // 確保列表有值且數量為20
        XCTAssertFalse(nextList.list.isEmpty)
        // 確保可以拿到下一頁
        XCTAssertNotEqual(nextList.nextPageToken, "")
        
        // 確保列表內容不為空
        for item in nextList.list {
            XCTAssertNotEqual(item.id, "")
            XCTAssertNotEqual(item.name, "")
            XCTAssertNotNil(item.thumbnails.thumbnailsDefault)
        }
    }
    
    func testToGetCommentThreadList() async throws {
        let commentList = await CommentThreadList.fetchDataFrom(service, .firstPage(id: test_vidoeID))
        XCTAssertNotNil(commentList)
        guard let commentList = commentList else { return }
        // 確保列表有值
        XCTAssertFalse(commentList.list.isEmpty)
        // 確保可以拿到下一頁
        XCTAssertNotEqual(commentList.nextPageToken, "")
        // 確保列表內容不為空
        for item in commentList.list {
            // 確保留言串ID可拿到
            XCTAssertNotEqual(item.threadID, "")
            XCTAssertNotNil(item.thumbnail)
            guard item.subCommentCount > 0 else { continue }
            for subComment in item.subComments {
                XCTAssertNotNil(subComment.thumbnail)
            }
        }
        print("--------------------------------")
        let nextList = await CommentThreadList.fetchDataFrom(service, .nextPage(id: test_vidoeID, token: commentList.nextPageToken))
        XCTAssertNotNil(nextList)
        guard let nextList = nextList else { return }
        // 確保列表有值
        XCTAssertFalse(nextList.list.isEmpty)
        // 確保可以拿到下一頁
        XCTAssertNotEqual(nextList.nextPageToken, "")
        // 確保內容不為空
        for item in nextList.list {
            // 確保留言串ID可拿到
            // 確保留言串ID可拿到
            XCTAssertNotEqual(item.threadID, "")
            XCTAssertNotNil(item.thumbnail)
            guard item.subCommentCount > 0 else { continue }
            for subComment in item.subComments {
                XCTAssertNotNil(subComment.thumbnail)
            }
        }
    }
}
