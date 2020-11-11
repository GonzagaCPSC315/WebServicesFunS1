//
//  FlickrAPI.swift
//  WebServicesFun
//
//  Created by Gina Sprint on 11/3/20.
//  Copyright © 2020 Gina Sprint. All rights reserved.
//

import Foundation

struct FlickrAPI {
    // it is BAD PRACTICE to put an API key in your code
    // typically you put it in an encrypted file, or in keychain services, or even in your Info.plist (add Info.plist .gitignore file)
    static let apiKey = "1e62fea963ae2caf0854ae1be8fee7fd"
    static let baseURL = "https://api.flickr.com/services/rest"
    
    // the first thing we wanna do is construct or flickr.interestingness.getList url request for data
    static func flickrURL() -> URL {
        // first lets define our query parameters
        let params = [
            "method": "flickr.interestingness.getList",
            "api_key": FlickrAPI.apiKey,
            "format": "json",
            "nojsoncallback": "1", // asks for raw JSON
            "extras": "date_taken,url_h" // url_h is for a 1600px image url for the photo
        ]
        // now we need to get the params into a url with the base ulr
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: FlickrAPI.baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
    }
    
    // lets define a function to make the request using the url we just constructed
    static func fetchInterestingPhotos() {
        let url = FlickrAPI.flickrURL()
        
        // now we need to make the request and get the JSON data back
        // we will use a background task to do this
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            // this closure executes later...
            // when the task gets a respone from the Flickr API server
            // could be an error!!
            // the JSON data (if its there) will be in dataOptional (of type Data?)
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print("we got data!!")
                print(dataString)
                // we need to parse the Data response
                // into JSON, then parse the JSON
                // into an [InterestingPhoto]
                // write a method to do this
                if let interestingPhotos = interestingPhotos(fromData: data) {
                    print("we got [InterestingPhoto] with \(interestingPhotos.count) photos")
                    // to pass the array back to ViewController for displaying
                }
            }
            else {
                if let error = errorOptional {
                    print("Error getting the Data \(error)")
                }
            }
        }
        // by default tasks are created in the suspended state
        // call resume() to start the task
        task.resume()
    }

    static func interestingPhotos(fromData data: Data) -> [InterestingPhoto]? {
        // if anything goes wrong, return nil
        
        return nil
    }
}
