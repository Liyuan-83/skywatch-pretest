//
//  HttpServiceTest.swift
//  skywatch_pretestTests
//
//  Created by liyuan chang on 2023/7/22.
//

import XCTest
@testable import skywatch_pretest

final class HttpServiceTest: XCTestCase {

    func testToGetChannelInfo() async throws {
        let service = HttpService<ChannelInfo>()
        let channelInfo = await ChannelInfo.fetchDataFrom(service, .info)
        XCTAssertNotNil(channelInfo)
        guard let channelInfo = channelInfo else { return }
        //確保要顯示的內容有名字、描述、uploadID、縮圖
        XCTAssertNotNil(channelInfo.name)
        XCTAssertNotNil(channelInfo.description)
        XCTAssertNotNil(channelInfo.uploadID)
        XCTAssertNotNil(channelInfo.thumbnails)
    }
    
    func testToGetPlayList() async throws {
        let service = HttpService<PlayList>()
        let playList = await PlayList.fetchDataFrom(service, .firstPage(id: test_playListID))
        XCTAssertNotNil(playList)
        guard let playList = playList else { return }
        
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
        let nextList = await PlayList.fetchDataFrom(service, .nextPage(id: test_playListID, token: nextPageToken))
        XCTAssertNotNil(nextList)
        guard let nextList = nextList else { return }
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
        let service = HttpService<CommentThreadList>()
        let commentList = await CommentThreadList.fetchDataFrom(service, .firstPage(id: test_vidoeID))
        XCTAssertNotNil(commentList)
        guard let commentList = commentList else { return }
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
            print("\(item.authorName):\(item.content) Like:\(item.likeCount)")
            guard item.subCommentCount > 0 else { continue }
            for subComment in item.subComments{
                XCTAssertNotNil(subComment.thumbnail)
                print("|-- \(subComment.authorName):\(subComment.content) Like:\(subComment.likeCount)")
            }
        }
        print("--------------------------------")
        let nextList = await CommentThreadList.fetchDataFrom(service, .nextPage(id: test_vidoeID, token: nextPageToken))
        XCTAssertNotNil(nextList)
        guard let nextList = nextList else { return }
        //確保列表有值且數量為30
        XCTAssertNotNil(nextList.list)
        XCTAssertEqual(nextList.list?.count, 20)
        //確保可以拿到下一頁
        XCTAssertNotNil(nextList.nextPageToken)
        guard let nlist = nextList.list else { return }
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
