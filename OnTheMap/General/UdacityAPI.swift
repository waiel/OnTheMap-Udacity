//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Waiel Eid on 10/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import MapKit
import UIKit


class UdacityAPI {
    // MARK: - variables defined
    static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let udacityBaseURL: URL = URL(string: "https://onthemap-api.udacity.com/v1/session")!
    static let parseBaseURL: URL = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt&limit=100")!

    /// MARK: login session request
    static func postLogin(email: String, password: String, completion: @escaping([String:Any]?, Error?) -> ()){
        var request = URLRequest(url: udacityBaseURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.httpBody = "{\"Udacity\" : {\"username\": \"\(email)\", \"password\" : \"\(password)\"}}".data(using: .utf8)

        _ = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(nil,error)
                return
                
            }
            guard let response = response as? HTTPURLResponse else {
                completion(nil,error)
                return
                
            }
            guard response.statusCode >= 200 && response.statusCode < 400 else {
                let reply = ["error" : "Authorization Failed" ]
                completion(reply, nil)
                return
                
            }
            guard let data = data else {
                completion(nil,error)
                return
                
            }
            
            let newData = data.subdata(in: 5..<data.count)
            print(String(data: newData, encoding: .utf8)!)
            let result = try! JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
            completion(result,nil)
        }.resume()
        
    }
    
    /// MARK: logout session request
    static func postLogout(completion: @escaping(Error?) -> ()){
        var request = URLRequest(url: udacityBaseURL)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        _ = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(error)
                return
                
            }
            guard let response = response as? HTTPURLResponse else {
                completion(error)
                return
                
            }
            guard response.statusCode >= 200 && response.statusCode < 400 else {
                completion(error)
                return
                
            }
            guard let data = data else {
                completion(error)
                return
                
            }
            let newData = data.subdata(in: 5..<data.count)
            print(String(data: newData, encoding: .utf8)!)
            completion(nil)
        }.resume()
    }

    
    // MARK: student locaiton request
    static func postStudentLocation(link: String, locations: CLLocationCoordinate2D, locationName: String, completion: @escaping (Error?) -> ()){
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue(AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        request.httpBody = "{\"uniqueKey\": \"1234567890\", \"firstName\": \"Waiel\", \"lastName\": \"Eid\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(link)\",\"latitude\": \(locations.latitude), \"longitude\": \(locations.longitude)}".data(using: .utf8)

        _  = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(error)
                return
                
            }
            guard let response = response as? HTTPURLResponse else {
                completion(error)
                return
                
            }
            guard response.statusCode >= 200 && response.statusCode < 400 else {
                completion(error)
                return
                
            }
            guard let data = data else {
                completion(error)
                return
                
            }
            print(String(data: data, encoding: .utf8)!)
            completion(nil)
        }.resume()
    }
    
    /// MARK: get student locaiton request
    static func getStudentsLocaiton(completion: @escaping([StudentLocation]?, Error?) -> ()){
        var request = URLRequest(url: parseBaseURL)
        request.addValue(AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        _ = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(nil,error)
                return
                
            }
            guard let response = response as? HTTPURLResponse else {
                completion(nil,error)
                return
                
            }
            guard response.statusCode >= 200 && response.statusCode < 400 else {
                completion(nil,response.statusCode as? Error)
                return
                
            }
            guard let data = data else {
                completion(nil,error)
                return
                
            }
            
            print(String(data: data, encoding: .utf8)!)
            let reply = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String:Any]
            guard let result = reply["results"] as? [[String:Any]] else {
                completion(nil, error)
                return
            }
            
            let resultData = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
            let studentsLocations = try! JSONDecoder().decode([StudentLocation].self, from: resultData)
            Globals.shared.studentsLocations = studentsLocations
            completion(studentsLocations,nil)
            
        }.resume()
        
        
    }
    
}

