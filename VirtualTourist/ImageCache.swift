//
//  ImageCache.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 19/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import Foundation

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do{
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }catch let error as NSError  {
                print(error)
            }
            
            return
        }
        
        inMemoryCache.setObject(image!, forKey: path)
        let data = UIImagePNGRepresentation(image!)
        data!.writeToFile(path, atomically: true)
    }
}