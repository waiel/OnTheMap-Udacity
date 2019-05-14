//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Waiel Eid on 11/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    
    // MARK: - variables defined
    let cellid="listTableViewCell"
    // get stored student locaitons
    var studentsLocations : [StudentLocation]! {
        return Globals.shared.studentsLocations
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // register class for resuing cells identificaiton
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // check if the student location collection is emtpy
        if (studentsLocations == nil){
            reloadStudentsLocations(self)
        }else{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBActions
    //logout button
    @IBAction func logout(_ sender: Any) {
        // send logout request to API
        UdacityAPI.postLogout { (error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // reload button
    @IBAction func reload(_ sender: Any) {
        self.reloadStudentsLocations(sender)
    }
    
    // Add locaiton button
    @IBAction func addPinClicked(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "studentLocation") != nil{
            // check if user posted before
            let alert = UIAlertController(title: "Notice", message: "You Already Posted a location. Would you like to overwide it?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "listAddNewPin", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.performSegue(withIdentifier: "listAddNewPin", sender: self)
        }
    }
    
    
    // reload the student locaitons collection
    func reloadStudentsLocations(_ sender: Any) {
        // get the student locations from API
        UdacityAPI.getStudentsLocaiton { (studentsLocations, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - Table view ovrride functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsLocations?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath)
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = (studentsLocations[indexPath.row].firstName ?? "") + " " + (studentsLocations[indexPath.row].lastName ?? "")
        cell.detailTextLabel?.text = (studentsLocations[indexPath.row].mediaURL ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentsLocations[indexPath.row]
        guard let toOpen = studentLocation.mediaURL , let url = URL(string: toOpen) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
