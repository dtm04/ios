//
//  CreatePartyViewController.swift
//  Medli
//
//  Created by Don MacPhail on 10/12/18.
//  Copyright © 2018 Medli. All rights reserved.
//

import UIKit
import Alamofire

class CreatePartyViewController: UIViewController {
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pswdTextField: UITextField!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func joinPartyButton(_ sender: Any) {
        let postURL = "https://medlimusic.com/joinPot"
        let p1: String = nameTextField.text!
        let p2: String = pswdTextField.text!
        let params: Parameters = [
            "name": p1,
            "password": p2
        ]
        serverRequest(URL: postURL, params: params)
    }
    
    @IBAction func createPartyButton(_ sender: Any) {
        let postURL = "https://medlimusic.com/createPot"
        let p1: String = nameTextField.text!
        let params: Parameters = [
            "name": p1,
        ]
        serverRequest(URL: postURL, params: params)
    }
    
    func serverRequest(URL: String, params: Parameters) {
        Alamofire.request(URL, method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.result.value {
                    print("RESPONSE: \(json)")
                    self.setParty(data: json)
                }
            //guestParty.potID =
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setParty(data: Any) {
        let hostParty = Party(json: data as! [String : Any])
        //GlobalParties.guestParty = guestParty!
        GlobalParties["HOST"] = hostParty
        print(GlobalParties["HOST"]?.potID)
        print("Global Party: \(GlobalParties["HOST"]?.potID)")
    }
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    @IBAction func connectSpotify(_ sender: Any) {
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
        appDelegate?.sessionManager.initiateSession(with: scope, options: .clientOnly)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Load View" {
            if let HostVC = segue.destination as? HostViewController {
                HostVC.currentParty = GlobalParties["HOST"]!
            }
        }
    }

}
