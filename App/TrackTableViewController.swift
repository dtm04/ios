//
//  TrackTableViewController.swift
//  medli-ios
//
//  Created by Don MacPhail on 10/24/18.
//  Copyright © 2018 Medli. All rights reserved.
//

import UIKit
import Foundation
import Spartan
import Alamofire

protocol TrackDelegate: AnyObject {
    func didSelectTrack(track: Track)
}

class TrackTableViewController: UITableViewController {
    weak var delegate:TrackDelegate?
    var trackName: String = ""
    typealias standardJSON = [String: AnyObject]
    var tableData = [Track]()
    var searchText: String? = nil
    
    //token for testing purposes only
    //user token located at AppDelegate.sharedInstance.appRemote.connectionParameters.accessToken
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search(query: searchText!)
        //Debug method
        //setToken(token: token)
    }
    
    func search(query: String) {
        Spartan.authorizationToken = GlobalToken
        _ = Spartan.search(query: query, type: .track, success: { (pagingObject: PagingObject<SimplifiedTrack>) in
            // Get the artists via pagingObject.items
            self.display(data: pagingObject)
        }, failure: { (error) in
            print(error)
        })
    }
    
    func setToken(token: String) {
        //check if token is nil, show error message if it is
        //let token = AppDelegate.sharedInstance.appRemote.connectionParameters.accessToken
        //print(token)
    }
    
    func display(data: PagingObject<SimplifiedTrack>) {
        for i in data.items {
            let track = Track(id: i.id as! String, name: i.name)
            tableData.append(track)
            //print(i.name)
        }
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = tableData[indexPath.row].trackName
        return cell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = self.tableData[indexPath.row]
        print("selected: ", track.trackID)
        delegate?.didSelectTrack(track: track)
        if delegate != nil {
            delegate?.didSelectTrack(track: track)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        performSegueToReturnBack()
        //navigationController?.popViewController(animated: true)
    }
}
