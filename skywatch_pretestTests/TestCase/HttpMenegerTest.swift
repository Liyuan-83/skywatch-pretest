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
        let channelInfo = try await meneger.getChannelInfo(YOASOBI_Channel_ID)
        //確保要顯示的內容有名字、描述、uploadID、縮圖
        XCTAssertNotNil(channelInfo.name)
        XCTAssertNotNil(channelInfo.description)
        XCTAssertNotNil(channelInfo.uploadID)
        XCTAssertNotNil(channelInfo.thumbnails)
    }
    
    func testToGetPlayList() async throws {
        let meneger = HttpMeneger()
        let playList = try await meneger.getPlayList(test_playListID)
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
        let nextList = try await meneger.getPlayList(test_playListID, 20, nextPageToken)
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
    
    func testToGetCommentThreadList() async throws {
        let meneger = HttpMeneger()
        let commentList = try await meneger.getCommentThreadList(test_vidoeID)
        //確保列表有值且數量為30
        XCTAssertNotNil(commentList.list)
        XCTAssertEqual(commentList.list?.count, 30)
        //確保可以拿到下一頁
        XCTAssertNotNil(commentList.nextPageToken)
        guard let list = commentList.list,
              let nextPageToken = commentList.nextPageToken else { return }
        //確保列表內容不為空
        for item in list{
            //確保留言串ID可拿到
            XCTAssertNotNil(item.threadID)
            XCTAssertNotNil(item.thumbnail)
            //最多好像只有五筆，更多要用comment api拿
//            XCTAssertEqual(item.subCommentCount > 5 ? 5 : item.subCommentCount, item.subComments.count )
            print("\(item.authorName):\(item.content) Like:\(item.likeCount)")
            guard item.subCommentCount > 0 else { continue }
            for subComment in item.subComments{
                XCTAssertNotNil(subComment.thumbnail)
                print("|-- \(subComment.authorName):\(subComment.content) Like:\(subComment.likeCount)")
            }
        }
        print("--------------------------------")
        let nextList = try await meneger.getCommentThreadList(test_vidoeID, 10, nextPageToken)
        //確保列表有值且數量為30
        XCTAssertNotNil(nextList.list)
        XCTAssertEqual(nextList.list?.count, 10)
        //確保可以拿到下一頁
        XCTAssertNotNil(nextList.nextPageToken)
        guard let nlist = commentList.list else { return }
        //確保內容不為空
        for item in nlist{
            //確保留言串ID可拿到
            XCTAssertNotNil(item.threadID)
            XCTAssertNotNil(item.thumbnail)
            print("\(item.authorName):\(item.content) Like:\(item.likeCount)")
            guard item.subCommentCount > 0 else { continue }
            for subComment in item.subComments{
                XCTAssertNotNil(subComment.thumbnail)
                print("|-- \(subComment.authorName):\(subComment.content) Like:\(subComment.likeCount)")
            }
        }
    }
}
