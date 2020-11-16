//
//  FlickrAPI.swift
//  WebServicesFun
//
//  Created by Gina Sprint on 11/3/20.
//  Copyright © 2020 Gina Sprint. All rights reserved.
//

import UIKit

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
    // @escaping tells the compiler that this completion closure executes after the method returns
    static func fetchInterestingPhotos(completion: @escaping ([InterestingPhoto]?) -> Void) {
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
                    // PROBLEMS!!
                    // MARK: - Threads
                    // so far, our code in ViewController (for example) is running on the main UI thread
                    // the main UI thread listens for user interactions, it calls callbacks in view controllers and delegates, etc.
                    // we don't want to run long running tasks/code on the main UI thread, why?
                    // it can make the UI unresponsive
                    // by default, URLSession dataTasks run on a background thread
                    // so that means this closure we are in now, runs asynchronously on a background thread
                    // we cannot simply return interestingPhotos array to viewDidLoad() because it has already returned
                    // we need a completion handler (AKA closure) that we call when we have a result
                    // we need to call completion from the main UI thread because it needs to update the UI
                    // a thread in iOS is managed by a queue
                    DispatchQueue.main.async {
                        completion(interestingPhotos)
                    }
                    // should completion(nil) on failure
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            else {
                if let error = errorOptional {
                    print("Error getting the Data \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        // by default tasks are created in the suspended state
        // call resume() to start the task
        task.resume()
    }

    static func interestingPhotos(fromData data: Data) -> [InterestingPhoto]? {
        // if anything goes wrong, return nil
        
        // MARK: - JSON
        // javascript object notation
        // most the common format for passing data around the web
        // JSON is just a dictionary
        // keys are strings
        // values are strings, nested JSON objects, arrays, ints, bools, etc.
        // our goal is to get the JSON data into a swift dictionary [String: Any]
        // there are libraries that make this really easy... swiftyJSON
        // we are going do this long way!!
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let photosObject = jsonDictionary["photos"] as? [String: Any], let photoArray = photosObject["photo"] as? [[String: Any]] else {
                print("Error parsing JSON")
                return nil
            }
            
            print("we got the photoArray")
            var interestingPhotos = [InterestingPhoto]()
            for photoObject in photoArray {
                // parse an InterestingPhoto from the photoObject JSON
                if let interestingPhoto = interestingPhoto(fromJSON: photoObject) {
                    interestingPhotos.append(interestingPhoto)
                }
            }
            // GS: added after class
            if !interestingPhotos.isEmpty {
                return interestingPhotos
            }
        }
        catch {
            print("Error coverting Data to JSON \(error)")
        }
        
        return nil
    }
    
    static func interestingPhoto(fromJSON json: [String: Any]) -> InterestingPhoto? {
        // task: finish this method...
        guard let id = json["id"] as? String, let title = json["title"] as? String, let dateTaken = json["datetaken"] as? String, let photoURL = json["url_h"] as? String else {
            return nil
        }
        
        // we have everything we need to make and return InterestingPhoto
        // GS: added after class
        return InterestingPhoto(id: id, title: title, dateTaken: dateTaken, photoURL: photoURL)
    }
    
    static func fetchImage(fromURLString urlString: String, completion: @escaping (UIImage?) -> Void) {
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let image = UIImage(data: data) {
                // task: call completion, pass in the image
                // update the UIImageView :)
            }
        }
        task.resume()
    }
}
