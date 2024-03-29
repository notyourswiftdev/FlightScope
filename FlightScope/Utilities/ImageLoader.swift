//
//  ImageLoader.swift
//  FlightScope
//
//  Created by Aaron Cleveland on 1/28/21.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()
class ImageLoader: UIImageView {

    var imageURL: URL?
    let activityIndicator = UIActivityIndicatorView()

    func loadImageWithUrl(_ url: URL) {
        // setup activityIndicator...
        activityIndicator.color = .darkGray
        
        addSubview(activityIndicator)
        activityIndicator.centerX(inView: self)
        activityIndicator.centerY(inView: self)
        imageURL = url
        image = nil
        activityIndicator.startAnimating()

        // retrieves image if already available in cache
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            self.image = imageFromCache
            activityIndicator.stopAnimating()
            return
        }

        // image does not available in cache.. so retrieving it from url...
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                print(error as Any)
                DispatchQueue.main.async(execute: {
                    self.activityIndicator.stopAnimating()
                })
                return
            }

            DispatchQueue.main.async(execute: {
                if let unwrappedData = data, let imageToCache = UIImage(data: unwrappedData) {
                    if self.imageURL == url {
                        self.image = imageToCache
                    }
                    imageCache.setObject(imageToCache, forKey: url as AnyObject)
                }
                self.activityIndicator.stopAnimating()
            })
        }).resume()
    }
}
