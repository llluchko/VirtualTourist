//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/26/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import UIKit

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
				let newError = FlickrClient.errorForResponse(data, response: response, error: error)
				completionHandler(result: nil, error: newError)
			} else {
				FlickrClient.parseJSONWithComplitionHandler(data!, completionHandler: completionHandler)
			}
		}
		
		
		task.resume()
		
	}
	
	// MARK: - Helpers
	
	// Given raw JSON, return a usable Foundation object
	class func parseJSONWithComplitionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
	
		var parsingError: NSError?
		let parsedResult: AnyObject?
		
		do {
			parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		} catch let error as NSError {
			parsingError = error
			parsedResult = nil
			print("Parsing error - \(parsingError!.localizedDescription)")
			return
		}
		
		if let error = parsingError {
			completionHandler(result: nil, error: error)
		} else {
			completionHandler(result: parsedResult, error: nil)
		}
	}
	
	
	// Get error for response 
	class func errorForResponse(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
		if let parsedResult  = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as? [String: AnyObject] {
			
			if let status = parsedResult[JSONResponseKeys.Status] as? String,
				message = parsedResult[JSONResponseKeys.Message] as? String {
				
				if status == JSONResponseValues.Fail {
					
					let userInfo = [NSLocalizedDescriptionKey: message]
					
					return NSError(domain: "Virtual Tourist Error", code: 1, userInfo: userInfo)
				}
			}
		}
		return error
	}
	
	// Substitute the key for the value that is contained within the method name
	class func substitudeKeyInMethod(method: String, key: String, value: String) -> String? {
		if method.rangeOfString("{\(key)}") != nil {
			return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
		} else {
			return nil
		}
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
	
	// Show error alert
	func showAlert(message: NSError, viewController: AnyObject) {
		let errMessage = message.localizedDescription
		
		let alert = UIAlertController(title: nil, message: errMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
			alert.dismissViewControllerAnimated(true, completion: nil)
		}))
		
		viewController.presentViewController(alert, animated: true, completion: nil)
	}
	
	// Open an URL
	func openURL(urlString: String) {
		let url = NSURL(string: urlString)
		UIApplication.sharedApplication().openURL(url!)
	}
	
	// Shared Instance
	class func sharedInstance() -> FlickrClient {
		struct Singleton {
			static var sharedInstance = FlickrClient()
		}
		return Singleton.sharedInstance
	}

}
