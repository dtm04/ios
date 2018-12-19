//
//  HostViewController.swift
//  Medli
//
//  Created by Don MacPhail on 10/12/18.
//  Copyright © 2018 Medli. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire
import Spartan

protocol PartyDelegate: AnyObject {
    func hasCurrentParty(party: Party)
}

class HostViewController: UIViewController, SPTAppRemotePlayerStateDelegate, SPTAppRemoteUserAPIDelegate, SKStoreProductViewControllerDelegate {
    
    
    //Get these values using Spotify SDK
    fileprivate var defaultPlayURI = "spotify:album:5uMfshtC2Jwqui0NUyUYIL"
    fileprivate var trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    fileprivate var connectionIndicatorView = ConnectionStatusIndicatorView()

    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet var buttons: [UIBarButtonItem]!
    @IBOutlet weak var refreshButton: UIButton!
    
    fileprivate var playerState: SPTAppRemotePlayerState?
    fileprivate var subscribedToPlayerState: Bool = false
    
    //DEBUG: for testing.  this party should contain a now playing song
    var potID: String = ""
    var currentParty: Party = Party()
    var currentTrack: Track = Track()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //trackName.isHidden = true
    }
    
    func serverRequest(postURL: String) {
        //var spotifyID: String = ""
        let id: String = GlobalParties["HOST"]!.potID
        let params: Parameters = [
            "potId": id
        ]
        
        Alamofire.request(postURL, method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
            case .success:
                print(response.result)
                if let result = response.result.value {
                    print("RESPONSE: \(result)")
                    let JSON = result as! NSDictionary
                    let spotifyID = JSON.object(forKey: "now_playing_spotify_id")
                    self.currentParty.nowPlayingID = spotifyID as! String
                    print("Now playing (current party): \(self.currentParty.nowPlayingID)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    
    
    func getNextSongServerRequest(postURL: String) {
        let id: String = GlobalParties["HOST"]!.potID
        let params: Parameters = [
            "potId": id
        ]
        
        Alamofire.request(postURL, method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
            case .success:
                print(response.result)
                if let result = response.result.value {
                    print("RESPONSE: \(result)")
                    let JSON = result as! NSDictionary
                    let spotifyID = JSON.object(forKey: "spotify_id")
                    self.currentParty.nowPlayingID = spotifyID as! String
                    print("Now playing (current party): \(self.currentParty.nowPlayingID)")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    fileprivate func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        appRemoteConnected()
        trackName.text = playerState.track.name + " - " + playerState.track.artist.name
        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
            self.updateAlbumArtWithImage(image)
        }
        //updateViewWithRestrictions(playerState.playbackRestrictions)
    }
    
    fileprivate func updateViewWithRestrictions(_ restrictions: SPTAppRemotePlaybackRestrictions) {
        nextButton.isEnabled = restrictions.canSkipNext
    }
    
    fileprivate func enableInterface(_ enabled: Bool = true) {
        buttons.forEach { (button) -> () in
            button.isEnabled = enabled
        }
        
        if (!enabled) {
            albumArtImageView.image = nil
            updatePlayPauseButtonState(true);
        }
    }
    @IBAction func refreshPressed(_ sender: Any) {
        getNowPlaying()
        fetchSongInfo()
        print("Spotify URI? --> \(currentTrack.playURI)")
    }
    
    func getNowPlaying() {
        let postURL = "https://medlimusic.com/nowPlaying"
        serverRequest(postURL: postURL)
    }
    
    func fetchSongInfo() {
        print("Fetching information for: \(currentParty.nowPlayingID)")
        let authString = "Bearer " + GlobalToken
        let headers: HTTPHeaders = [
            "Authorization": authString
        ]
        
        let spotifyUrl = "https://api.spotify.com/v1/tracks/" + currentParty.nowPlayingID
        Alamofire.request(spotifyUrl, headers: headers).responseJSON { response in
            if let json = response.result.value {
                //print("SPOTIFY RESPONSE: \(json)")
                self.parseJson(json: json as! [String : Any])
            }
        }
    }
    
    func parseJson(json: [String: Any]) {
        /*
        if let name = json["name"] as? String {
            print("GOT NAME -- \(name)")
            currentTrack.trackName = name
            //currentTrack?.trackName = name
        }
        
        if let artist = json["artists"] as? [Any] {
            if let artName = artist[0] as? [String: Any]{
                let n = artName["name"]
                print("ARTIST NAME -- \(n)")
            }
        }
        
        if let nested = json["album"] as? [String: Any] {
            if let images = nested["i   mages"] as? [Any] {
                if let first = images[0] as? [String: Any] {
                    let imgUrl = first["url"]
                    print("GOT URL -- \(imgUrl)")
                    currentTrack.imageURL = imgUrl as! String
                }
            }
        } */
        
        if let id = json["id"] as? String {
            let currID = id
            print("GOT ID -- \(currID)")
        }
        
        if let uri = json["uri"] as? String {
            currentTrack.playURI = uri
        }
    }
    
    @IBAction func playPressed(_ sender: Any) {
        if !(appRemote.isConnected) {
            if (!appRemote.authorizeAndPlayURI(currentTrack.playURI ?? defaultPlayURI)) {
                // The Spotify app is not installed, present the user with an App Store page
                print("ERROR: cannot run on iOS simulator")
            }
        } else if playerState == nil || playerState!.isPaused {
            print("DEBUG-----> \(currentTrack.playURI)")
            playTrackWithIdentifier(currentTrack.playURI!)
            //trackName.isHidden = false
        }
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        pausePlayback()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        //https://medlimusic.com/playNextSong
        //"potId": "2274473"
        let url = "https://medlimusic.com/playNextSong"
        //serverRequest(postURL: url)
        //fetchSongInfo()
        getNextSongServerRequest(postURL: url)
        fetchSongInfo()
        playTrackWithIdentifier(currentTrack.playURI!)
    }
    

    
    fileprivate func updatePlayPauseButtonState(_ paused: Bool)  {
        playButton.isEnabled = paused
        pauseButton.isEnabled = paused
        nextButton.isEnabled = paused
    }
    
    //Mark: - ALbum art
    @IBOutlet weak var albumArtImageView: UIImageView!
    fileprivate func updateAlbumArtWithImage(_ image: UIImage) {
        self.albumArtImageView.image = image
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.albumArtImageView.layer.add(transition, forKey: "transition")
    }
    
    // MARK: - Image API
    fileprivate func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        appRemote.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
    
    var appRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.appRemote
        }
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    //error handling
    fileprivate func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }
    //error displaying
    fileprivate func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - SDK Player State functions
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }
    
    fileprivate func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }
    
    fileprivate func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }
    
    fileprivate func pausePlayback() {
        if(playerState!.isPaused) {
            return
        } else {
            appRemote.playerAPI?.pause(defaultCallback)
        }
    }
    
    fileprivate func playTrack() {
        appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
        getPlayerState()
    }
    
    fileprivate func enqueueTrack() {
        appRemote.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }
    
    fileprivate func toggleShuffle() {
        guard let playerState = playerState else { return }
        appRemote.playerAPI?.setShuffle(!playerState.playbackOptions.isShuffling, callback: defaultCallback)
    }
    
    fileprivate func getPlayerState() {
        appRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
    }
    
    fileprivate func playTrackWithIdentifier(_ identifier: String) {
        appRemote.playerAPI?.play(identifier, callback: defaultCallback)
    }
    
    fileprivate func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote.playerAPI!.delegate = self
        appRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
        }
    }
    
    fileprivate func unsubscribeFromPlayerState() {
        guard (subscribedToPlayerState) else { return }
        appRemote.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = false
        }
    }
    
    fileprivate func toggleRepeatMode() {
        guard let playerState = playerState else { return }
        let repeatMode: SPTAppRemotePlaybackOptionsRepeatMode = {
            switch playerState.playbackOptions.repeatMode {
            case .off: return SPTAppRemotePlaybackOptionsRepeatMode.track
            case .track: return SPTAppRemotePlaybackOptionsRepeatMode.context
            case .context: return SPTAppRemotePlaybackOptionsRepeatMode.off
            }
        }()
        
        appRemote.playerAPI?.setRepeatMode(repeatMode, callback: defaultCallback)
    }
    
    // MARK: - <SPTAppRemotePlayerStateDelegate>
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    // MARK: - <SPTAppRemoteUserAPIDelegate>
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        //updateViewWithCapabilities(capabilities)
    }
    
    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - User API
    fileprivate var subscribedToCapabilities: Bool = false
    
    fileprivate func fetchUserCapabilities() {
        appRemote.userAPI?.fetchCapabilities(callback: { (capabilities, error) in
            guard error == nil else { return }
            let capabilities = capabilities as! SPTAppRemoteUserCapabilities
            self.subscribedToCapabilities = capabilities.canPlayOnDemand
        })
    }
    
    fileprivate func subscribeToCapabilityChanges() {
        guard (!subscribedToCapabilities) else { return }
        appRemote.userAPI!.delegate = self
        appRemote.userAPI?.subscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }
            
            self.subscribedToCapabilities = true
        })
    }
    
    fileprivate func unsubscribeFromCapailityChanges() {
        guard (subscribedToCapabilities) else { return }
        AppDelegate.sharedInstance.appRemote.userAPI?.unsubscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }
            
            self.subscribedToCapabilities = false
        })
    }
    
    // MARK: - appremote
    func appRemoteConnecting() {
        connectionIndicatorView.state = .connecting
    }
    
    func appRemoteConnected() {
        connectionIndicatorView.state = .connected
        subscribeToPlayerState()
        subscribeToCapabilityChanges()
        getPlayerState()
        
        enableInterface(true)
    }
    
    func appRemoteDisconnect() {
        connectionIndicatorView.state = .disconnected
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
        enableInterface(false)
    }

}
