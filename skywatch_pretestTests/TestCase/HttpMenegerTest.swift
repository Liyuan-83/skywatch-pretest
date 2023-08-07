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
        let meneger = HttpMeneger<ChannelInfo>()
        let res = await meneger.fetchData(["id":YOASOBI_Channel_ID], [.contentDetails, .snippet, .statistics])
        switch res{
        case .success(let channelInfo):
            //確保要顯示的內容有名字、描述、uploadID、縮圖
            XCTAssertNotNil(channelInfo.name)
            XCTAssertNotNil(channelInfo.description)
            XCTAssertNotNil(channelInfo.uploadID)
            XCTAssertNotNil(channelInfo.thumbnails)
        case .failure(let error):
            throw error
        }
        
    }
    
    func testToGetPlayList() async throws {
        let meneger = HttpMeneger<PlayList>()
        let res = await meneger.fetchData(["playlistId":test_playListID,
                                           "maxResults":30], [.snippet])
        var token = ""
        switch res{
        case .success(let playList):
            //確保列表有值且數量為30
            XCTAssertNotNil(playList.list)
            XCTAssertEqual(playList.list?.count, 30)
            //確保可以拿到下一頁
            XCTAssertNotNil(playList.nextPageToken)
            guard let list = playList.list,
                  let nextPageToken = playList.nextPageToken else { return }
            token = nextPageToken
            //確保列表內容不為空
            for item in list{
                XCTAssertNotNil(item.id)
                XCTAssertNotNil(item.createDate)
                XCTAssertNotNil(item.description)
                XCTAssertNotNil(item.name)
                XCTAssertNotNil(item.thumbnails)
                print(item.name!)
            }
        case .failure(let error):
            throw error
        }
        print("--------------------------------")
        let nextRes = await meneger.fetchData(["playlistId":test_playListID,
                                               "maxResults":20,
                                               "pageToken":token], [.snippet])
        switch nextRes{
        case .success(let nextList):
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
        case .failure(let error):
            throw error
        }
    }
    
    func testToGetCommentThreadList() async throws {
        let meneger = HttpMeneger<CommentThreadList>()
        let res = await meneger.fetchData(["videoId":test_vidoeID,
                                           "maxResults":30,
                                           "order":"relevance"],
                                          [.snippet,.replies])
        var token = ""
        switch res{
        case .success(let commentList):
            //確保列表有值且數量為30
            XCTAssertNotNil(commentList.list)
            XCTAssertEqual(commentList.list?.count, 30)
            //確保可以拿到下一頁
            XCTAssertNotNil(commentList.nextPageToken)
            guard let list = commentList.list,
                  let nextPageToken = commentList.nextPageToken else { return }
            token = nextPageToken
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
        case .failure(let error):
            throw error
        }
        print("--------------------------------")
        let nextRes = await meneger.fetchData(["videoId":test_vidoeID,
                                               "maxResults":20,
                                               "order":"relevance",
                                               "pageToken":token],
                                              [.snippet,.replies])
        
        switch nextRes{
        case .success(let nextList):
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
        case .failure(let error):
            throw error
        }
        
    }
}
