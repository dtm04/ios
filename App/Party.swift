//
//  Party.swift
//  medli-ios
//
//  Created by Don MacPhail on 12/3/18.
//  Copyright © 2018 Medli. All rights reserved.
//

import Foundation

class Party {
    var potID: String = ""
    //var potName: String = ""
    var numMixers: Int
    var nowPlayingID: String
    
    func getPartyId() -> String {
        return self.potID
    }
    //JOIN PARTY: pot_id
    //CREATE PARTY: potId
    init?(json: [String: Any]) {
        guard let mixers = json["number_of_mixers"] as? Int,
            let id = json["pot_id"] as? String
            //let name = json["name"] as? String
            else {
                return nil
        }
        
        //self.potName = name
        self.potID = id
        self.numMixers = mixers
        if let nowPlaying = json["now_playing_spotify_id"] as? String {
            self.nowPlayingID = nowPlaying
        } else {
            self.nowPlayingID = "NONE"
        }
    }
    
    init(id: String, mixers: Int) {
        self.potID = id
        //self.potName = name
        self.numMixers = mixers
        self.nowPlayingID = ""
    }
    
    init() {
        self.potID = ""
        self.numMixers = 0
        self.nowPlayingID = ""
    }
}
