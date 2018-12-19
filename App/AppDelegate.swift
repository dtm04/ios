//
//  AppDelegate.swift
//  Medli
//
//  Created by Don MacPhail on 10/11/18.
//  Copyright © 2018 Medli. All rights reserved.
//

import UIKit

var GlobalParties: [String: Party] = [:]
let GlobalToken = "BQD5lsTFhfBpbMli1kKAsfslwgEXbXlS9_o7T3rv7svpAgsecjV3oy_nwVyKitMdOoBnta98AR_p1Sk_eFju4c_3cAV3lTMpKd8kzgqA5WOyA8_X8xzXX9wW3MZIcRedWrj_pmTatfUyUZ8jtQ"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    var window: UIWindow?
    //var playerViewController: HostViewController?

    let SpotifyClientID = "2da93d82faff4116aaf8f310548693ae"
    let SpotifyRedirectURI = URL(string: "SeniorProject://returnAfterLogin")!
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI
    )
    
    /*
     performs token swap on a secure test environment (glitch, provided by spotify)
     token management MUST be done on a back end server to preserve client secret
     https://developer.spotify.com/documentation/general/guides/authorization-guide/
     */
    lazy var sessionManager: SPTSessionManager = {
        if let tokenSwapURL = URL(string: "https://spotify-token-swap.glitch.me/api/token"),
            let tokenRefreshURL = URL(string: "https://spotify-token-swap.glitch.me/api/refresh_token") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
            self.configuration.playURI = ""
            //leave playURI empty to resume playback
            //or provide a valid spotify URI eg:spotify:track:20I6sIOMTCkB6w7ryavxtO
        }
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        return manager
    }()

    //MARK: - SPTSessionManagerDelegate
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        self.appRemote.connectionParameters.accessToken = session.accessToken
        self.appRemote.connect()
        print("success", session)
    }
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("renewed", session)
    }
    
    //MARK: - SPTAppRemoteDelegate
    //initialize app remote
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()
    
    var playerViewController: HostViewController {
        //Need to get the viewcontroller that requires access to spotify
        //right now just using the HostViewController
        get {
            let topMostViewController = UIApplication.shared.topMostViewController()
            return topMostViewController as! HostViewController
        }
    }
    
    class var sharedInstance: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    //when user sucessfully returns to app, notify session manager about implementing this method
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.sessionManager.application(app, open: url, options: options)
        self.sessionManager.application(app, open: url, options: options)
        let parameters = appRemote.authorizationParameters(from: url);
     
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            //self.accessToken = access_token
         } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            playerViewController.showError(error_description);
         }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        playerViewController.appRemoteConnected()
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        playerViewController.appRemoteDisconnect()
        print("disconnected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        playerViewController.appRemoteDisconnect()
        print("failed")
    }
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Track name: %@", playerState.track.name)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    func connect() {
        playerViewController.appRemoteConnecting()
        appRemote.connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

