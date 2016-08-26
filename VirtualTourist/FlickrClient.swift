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
	
}
