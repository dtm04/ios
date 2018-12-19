//
//  JoinPartyViewController.swift
//  Medli
//
//  Created by Don MacPhail on 10/12/18.
//  Copyright © 2018 Medli. All rights reserved.
//

import UIKit
import Alamofire

class JoinPartyViewController: UIViewController {
    //var guestParty = Party()

    @IBOutlet weak var partyNameTextField: UITextField!
    @IBOutlet weak var partyIDTextField: UITextField!
    
    @IBAction func joinPartyButton(_ sender: Any) {
        let postURL = "https://medlimusic.com/joinPot"
        let partyName: String = partyNameTextField.text!
        let partyPswd: String = partyIDTextField.text!
        let params: Parameters = [
            "name": partyName,
            "password": partyPswd
        ]
        
        Alamofire.request(postURL, method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
            case .success:
                print(response.result)
                if let json = response.result.value {
                    print("RESPONSE: \(json)")
                    self.joinParty(data: json)
                }
                //guestParty.potID =
            case .failure(let error):
                print(error)
            }
        }
        //Alamofire.request("http://localhost:51997/joinPot", method: .post, parameters: params, encoding: JSONEncoding.default)
    }
    
    func joinParty(data: Any) {
        let guestParty = Party(json: data as! [String : Any])
        //GlobalParties.guestParty = guestParty!
        GlobalParties["GUEST"] = guestParty
        print("GLOBAL: \(GlobalParties["GUEST"]?.potID)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
