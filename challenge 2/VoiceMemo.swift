//
//  VoiceMemo.swift
//  challenge 2
//
//  Created by Chaima Ait Chafaai on 09/11/25.
//

import Foundation

struct VoiceMemo: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let url: URL
    let date: Date
    var transcription: String?
    var duration: TimeInterval
    
    init(id: UUID = UUID(), fileName: String, url: URL, date: Date = Date(), transcription: String? = nil, duration: TimeInterval = 0) {
        self.id = id
        self.fileName = fileName
        self.url = url
        self.date = date
        self.transcription = transcription
        self.duration = duration
    }
}
