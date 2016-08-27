//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/26/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
	
	var numOfPhotosDownloaded = 0
	
	// Shared session
	var session: NSURLSession
	
	override init() {
		session = NSURLSession.sharedSession()
		super.init()
	}
	
	func taskForGetMethodWithParams(parameters: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		
		// Build the URL and create the request
		let urlString = Constants.BaseURL + FlickrClient.escapedParameters(parameters)
		
		let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
		
		let task = session.dataTaskWithRequest(request) {
			data, response, downloadError in
			
			if let error = downloadError {
				// TO-DO: Create method errorForResponse
			} else {
				// TO-DO: Create method parseJSON
			}
		}
		
		
		task.resume()
		
	}
	
	// Given a dictionary of parameters, convert to a string for a url
	class func escapedParameters(parameters: [String : AnyObject]) -> String {
		
		var urlVars = [String]()
		
		for (key, value) in parameters {
			if(!key.isEmpty) {
				// Make sure that it is a string value
				let stringValue = "\(value)"
				
				// Escape it
				let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
				
				// Append it
				urlVars += [key + "=" + "\(escapedValue!)"]
			}
			
		}
		
		return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
	}

}
