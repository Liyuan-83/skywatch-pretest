//
//  YoutubeAPIPartEnum.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import Foundation

enum APIPart : String, CaseIterable{
    case auditDetails,brandingSettings,contentDetails,
         contentOwnerDetails,id,localizations,
         snippet,statistics,status,opicDetails,replies
}

enum VideosPart : String, CaseIterable{
    case contentDetails,fileDetails,id,liveStreamingDetails,
    localizations,player,processingDetails,recordingDetails,
    snippet,statistics,status,suggestions,topicDetails
}
