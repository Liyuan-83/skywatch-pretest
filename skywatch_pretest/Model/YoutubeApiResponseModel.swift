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
    var snippet: Snippet?
    var contentDetails: ContentDetails?
    var status: Status?
    var statistics: Statistics?
}

// MARK: - ContentDetails
struct ContentDetails: Codable {
    var videoID: String?
    var videoPublishedAt: Date?
    var relatedPlaylists: RelatedPlaylists?

    enum CodingKeys: String, CodingKey {
        case videoID = "videoId"
        case videoPublishedAt, relatedPlaylists
    }
}

// MARK: - RelatedPlaylists
struct RelatedPlaylists: Codable {
    var likes: String
    var uploads: String
}

// MARK: - Snippet
struct Snippet: Codable {
    var publishedAt: String?
    var channelID: String?
    var title, description: String?
    var thumbnails: Thumbnails?
    var channelTitle: String?
    var categoryID, liveBroadcastContent: String?
    var localized: Localized?
    var defaultAudioLanguage: String?
    var playlistID: String?
    var position: Int?
    var resourceID: ResourceID?
    var videoOwnerChannelTitle: String?
    var videoOwnerChannelID: String?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelID = "channelId"
        case title, description, thumbnails, channelTitle
        case categoryID = "categoryId"
        case liveBroadcastContent, localized, defaultAudioLanguage
        case playlistID = "playlistId"
        case position
        case resourceID = "resourceId"
        case videoOwnerChannelTitle
        case videoOwnerChannelID = "videoOwnerChannelId"
    }
}

// MARK: - Localized
struct Localized: Codable {
    var title, description: String?
}

// MARK: - ResourceID
struct ResourceID: Codable {
    var kind: Kind?
    var videoID: String?

    enum CodingKeys: String, CodingKey {
        case kind
        case videoID = "videoId"
    }
}

// MARK: - Thumbnails
struct Thumbnails: Codable {
    var thumbnailsDefault, medium, high, standard, maxres: ImageInfo?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault = "default"
        case medium, high, standard, maxres
    }
}

// MARK: - Default
struct ImageInfo: Codable {
    var url: String
    var width, height: Double
}

// MARK: - Status
struct Status: Codable {
    var privacyStatus: PrivacyStatus
}

enum PrivacyStatus: String, Codable {
    case pub = "public"
}

// MARK: - PageInfo
struct PageInfo: Codable {
    var totalResults, resultsPerPage: Double
}

// MARK: - Statistics
struct Statistics: Codable {
    var viewCount, subscriberCount: String
    var hiddenSubscriberCount: Bool
    var videoCount: String
}
