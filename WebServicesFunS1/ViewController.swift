//
//  ViewController.swift
//  WebServicesFunS1
//
//  Created by Gina Sprint on 11/10/20.
//

import UIKit
import MBProgressHUD

// MARK: - Flickr API Setup
// we are gonna build an app that will fetch
// information for interesting photos from the
// Flickr interstingness rest API
// we will construct a URL according to the Flickr API docs
// we will use URLSessionDataTask to send the rquest for data and get a Data object back
// our goal is to parse the JSON data that is in the Data object
// to create an array of [InterestingPhoto]
// we will define the InterestingPhoto type
// id, title, dateTaken, a photoURL
// we will use the photoURL later to get the actual image data

// we will define two types
// 1. InterestingPhoto
// 2. FlickrAPI which will have a bunch of static properties and method for our API to work with the Flickr API

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var interestingPhotos = [InterestingPhoto]()
    var currPhotoIndex: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // show the indeterminate progress bar while our background task is running
        // hide it when it is done
        MBProgressHUD.showAdded(to: self.view, animated: true)
        FlickrAPI.fetchInterestingPhotos { (interestingPhotosOptional) in
            if let interestingPhotos = interestingPhotosOptional {
                print("in ViewController got the array back")
                self.interestingPhotos = interestingPhotos
                self.currPhotoIndex = 0
                self.updateUI()
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            // task: show/hide the progress bar for fetching an image
        }
    }
    
    func updateUI() {
        if let index = currPhotoIndex {
            let photo = interestingPhotos[index]
            // update the title label, date label, and eventually the image view
            titleLabel.text = photo.title
            dateLabel.text = photo.dateTaken
            // fetch image...
            MBProgressHUD.showAdded(to: self.view, animated: true)
            FlickrAPI.fetchImage(fromURLString: photo.photoURL) { (imageOptional) in
                if let image = imageOptional {
                    self.imageView.image = image
                }
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            currPhotoIndex? += 1
            currPhotoIndex? %= interestingPhotos.count
        }
    }

    @IBAction func nextPhotoPressed(_ sender: UIButton) {
        print("next photo pressed")
        updateUI()
    }
}


