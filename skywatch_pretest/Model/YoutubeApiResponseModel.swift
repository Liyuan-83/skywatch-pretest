//
//  YoutubeApiResponseModel.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

// MARK: - YoutubeApiResponseModel
///Youtube API回傳的固定格式/
struct YoutubeApiResponse: Codable {
    var kind: ResposeKind
    var etag: String
    var items: [Item]
    var pageInfo: PageInfo
    var nextPageToken: String?
}

// MARK: - Item
struct Item: Codable {
    var kind: Kind
    var etag, id: String
    var snippet: ItemSnippet?
    var contentDetails: ContentDetails?
    var statistics: Statistics?
    var replies: Replies?
}

// MARK: - ContentDetails
struct ContentDetails: Codable {
    var relatedPlaylists: RelatedPlaylists?
}

// MARK: - RelatedPlaylists
struct RelatedPlaylists: Codable {
    var likes, uploads: String?
}

// MARK: - ItemSnippet
struct ItemSnippet: Codable {
    var title, description, customURL: String?
    var publishedAt: String?
    var thumbnails: Thumbnails?
    var localized: Localized?
    var country, channelID, channelTitle, playlistID: String?
    var position: Int?
    var resourceID: ResourceID?
    var videoOwnerChannelTitle, videoOwnerChannelID, categoryID, liveBroadcastContent: String?
    var defaultAudioLanguage, videoID: String?
    var topLevelComment: TopLevelComment?
    var canReply: Bool?
    var totalReplyCount: Int?
    var isPublic: Bool?

    enum CodingKeys: String, CodingKey {
        case title, description
        case customURL = "customUrl"
        case publishedAt, thumbnails, localized, country
        case channelID = "channelId"
        case channelTitle
        case playlistID = "playlistId"
        case position
        case resourceID = "resourceId"
        case videoOwnerChannelTitle
        case videoOwnerChannelID = "videoOwnerChannelId"
        case categoryID = "categoryId"
        case liveBroadcastContent, defaultAudioLanguage
        case videoID = "videoId"
        case topLevelComment, canReply, totalReplyCount, isPublic
    }
}

// MARK: - Replies
struct Replies: Codable {
    var comments: [Comment]
}

// MARK: - Comment
struct Comment: Codable {
    var kind, etag, id: String
    var snippet: TopLevelCommentSnippet
}

// MARK: - Localized
struct Localized: Codable {
    var title, description: String?
}

// MARK: - ResourceID
struct ResourceID: Codable {
    var kind, videoID: String?

    enum CodingKeys: String, CodingKey {
        case kind
        case videoID = "videoId"
    }
}

// MARK: - Thumbnails
struct Thumbnails: Codable {
    var thumbnailsDefault, medium, high, standard, maxres: Default?
    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault = "default"
        case medium, high, standard, maxres
    }
}

// MARK: - Default
struct Default: Codable {
    var url: String
    var width, height: Int
}

// MARK: - TopLevelComment
struct TopLevelComment: Codable {
    var kind, etag, id: String
    var snippet: TopLevelCommentSnippet
}

// MARK: - TopLevelCommentSnippet
struct TopLevelCommentSnippet: Codable {
    var videoID, textDisplay, textOriginal, authorDisplayName: String
    var authorProfileImageURL: String
    var authorChannelURL: String
    var authorChannelID: AuthorChannelID
    var canRate: Bool
    var viewerRating: String
    var likeCount: Int
    var publishedAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case videoID = "videoId"
        case textDisplay, textOriginal, authorDisplayName
        case authorProfileImageURL = "authorProfileImageUrl"
        case authorChannelURL = "authorChannelUrl"
        case authorChannelID = "authorChannelId"
        case canRate, viewerRating, likeCount, publishedAt, updatedAt
    }
}

// MARK: - AuthorChannelID
struct AuthorChannelID: Codable {
    var value: String
}

// MARK: - Statistics
struct Statistics: Codable {
    var viewCount, subscriberCount: String
    var hiddenSubscriberCount: Bool
    var videoCount: String
}

// MARK: - PageInfo
struct PageInfo: Codable {
    var totalResults, resultsPerPage: Int
}
