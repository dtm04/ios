//
//  Track.swift
//  medli-ios
//
//  Created by Don MacPhail on 12/3/18.
//  Copyright © 2018 Medli. All rights reserved.
//

// A Simple track class to manage track names and id's
import Foundation

class Track {
    var trackID: String
    var trackName: String
    var imageURL: String?
    var playURI: String?
    
    init(id: String, name: String) {
        self.trackID = id
        self.trackName = name
        self.imageURL = ""
    }
    
    init() {
        self.trackID = ""
        self.trackName = ""
        self.imageURL = ""
        self.playURI = ""
    }
    
    func getTrackId() -> String {
        return self.trackID
    }
    
    static func == (left: Track, right: Track) -> Bool {
        return left.trackID == right.trackID
    }
}
