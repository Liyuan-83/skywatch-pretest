//
//  YoutubeAPIPartEnum.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

enum ChannelsPart : String, CaseIterable{
    case auditDetails,brandingSettings,contentDetails,
         contentOwnerDetails,id,localizations,
         snippet,statistics,status,opicDetails
}

enum PlayListItemPart : String, CaseIterable{
    case contentDetails,id,snippet,status
}

enum VideosPart : String, CaseIterable{
    case contentDetails,fileDetails,id,liveStreamingDetails,
    localizations,player,processingDetails,recordingDetails,
    snippet,statistics,status,suggestions,topicDetails
}
