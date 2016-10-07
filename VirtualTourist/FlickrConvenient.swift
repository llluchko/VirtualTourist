
//
//  FlickrConvenient.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/26/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import CoreData

extension FlickrClient {
	
	// Initiates a download from Flickr
	func downloadPhotosForPin(pin: Pin, completionHandler: (success: Bool, error: NSError?) -> Void) {
		
		var randomPageNumber: Int = 1
		
		if let numberPages = pin.pageNumber?.integerValue {
			if numberPages > 0 {
				let pageLimit = min(numberPages, 20)
				randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1 }
		}
		
		// Parameters for request photos
		let parameters: [String : AnyObject] = [
			URLKeys.Method : Methods.Search,
			URLKeys.APIKey : Constants.APIKey,
			URLKeys.Format : URLValues.JSONFormat,
			URLKeys.NoJSONCallback : 1,
			URLKeys.Latitude : pin.latitude,
			URLKeys.Longitude : pin.longitude,
			URLKeys.Extras : URLValues.URLMediumPhoto,
			URLKeys.Page : randomPageNumber,
			URLKeys.PerPage : 21
		]
		
		// Make GET request for get photos for pin
		taskForGetMethodWithParams(parameters, completionHandler: {
			results, error in
			
			if let error = error {
				completionHandler(success: false, error: error)
			} else {
				
				// Response dictionary
				if let photosDictionary = results.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject],
					photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String : AnyObject]],
					numberOfPhotoPages = photosDictionary[JSONResponseKeys.Pages] as? Int {
					
					pin.pageNumber = numberOfPhotoPages
					
					self.numOfPhotoDownloaded = photosArray.count
					
					// Dictionary with photos
					for photoDictionary in photosArray {
						
						guard let photoURLString = photoDictionary[URLValues.URLMediumPhoto] as? String else {
							print ("error, photoDictionary)"); continue}


						
						// Create the Photos model
						let newPhoto = Photos(url: photoURLString, pin: pin, context: self.sharedContext)
						
						
						// Download photo by url
						self.downloadPhotoImage(newPhoto, completionHandler: {
							success, error in
							
							print("Downloading photo by URL - \(success): \(error)")
							
							self.numOfPhotoDownloaded = self.numOfPhotoDownloaded - 1
							
							// Posting NSNotifications
							NSNotificationCenter.defaultCenter().postNotificationName("downloadPhotoImage.done", object: nil)
							
							// Save the context
							dispatch_async(dispatch_get_main_queue(), {
								CoreDataStack.sharedInstance().saveContext()
							})
						})
					}
					
					completionHandler(success: true, error: nil)
				} else {
					
					completionHandler(success: false, error: NSError(domain: "downloadPhotosForPin", code: 0, userInfo: nil))
				}
			}
		})
	}
	
	// Download save image and change file path for photo
	func downloadPhotoImage(photo: Photos, completionHandler: (success: Bool, error: NSError?) -> Void) {
		
		let imageURLString = photo.url
		
		// Make GET request for download photo by url
		taskForGETMethod(imageURLString!, completionHandler: {
			result, error in
			
			// If there is an error - set file path to error to show blank image
			if let error = error {
				print("Error from downloading images \(error.localizedDescription )")
				//photo.filePath = "error"
				completionHandler(success: false, error: error)
				
			} else {
				
				if let result = result {
					
					photo.imageData = result
					
					completionHandler(success: true, error: nil)
				}
			}
		})
	}
	
	// MARK: - Core Data Convenience
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStack.sharedInstance().managedObjectContext
	}
	
}
