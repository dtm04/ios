//
//  GuestViewController.swift
//  Medli
//
//  Created by Don MacPhail on 10/12/18.
//  Copyright © 2018 Medli. All rights reserved.
//

import UIKit
import Alamofire
import Spartan

class GuestViewController: UIViewController, TrackDelegate {
    var guestTrack = Track()
    @IBOutlet weak var trackNameTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.isHidden = true
        yesButton.isEnabled = false
        noButton.isHidden = true
        noButton.isEnabled = false
        resultLabel.isHidden = true
        songLabel.isHidden = true
    }
    
    @IBAction func searchTrackButton(_ sender: Any) {
        //populate TableViewController with results
        _ = trackNameTextField.text!
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        print("DEBUG: \(guestTrack.trackID)")
        let pot = GlobalParties["GUEST"]!.potID
        let spotify = guestTrack.trackID
        let params: Parameters = [
            "potId": pot,
            "spotifyId": spotify
        ]
        
        //DEBUG
        print(params);
        
        Alamofire.request("https://medlimusic.com/addSong", method: .post, parameters: params).validate().responseJSON { response in
            print(response.result.description)
        }
        
        hideOptions(option: true)
        enableButtons(option: false)
        let resultString = guestTrack.trackName + " added!"
        resultLabel.text = resultString
        resultLabel.isHidden = false
    }
    
    @IBAction func noPressed(_ sender: Any) {
        hideOptions(option: true)
        enableButtons(option: false)
    }
    
    
    func didSelectTrack(track: Track) {
        print("User selected: ", track.trackID)
        guestTrack = track
        songLabel.text = guestTrack.trackName
        trackNameTextField.text = ""
        hideOptions(option: false)
        enableButtons(option: true)
    }
    
    func hideOptions(option: Bool) {
        yesButton.isHidden = option
        noButton.isHidden = option
        resultLabel.isHidden = option
        songLabel.isHidden = option
    }
    
    func enableButtons(option: Bool) {
        yesButton.isEnabled = option
        noButton.isEnabled = option
    }
    
    //get the new view controller with segue.destination
    //pass data to new view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let TrackTableViewController = segue.destination as? TrackTableViewController {
            TrackTableViewController.delegate = self
            TrackTableViewController.searchText = trackNameTextField.text
        }
    }
}
