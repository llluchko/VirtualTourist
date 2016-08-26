//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/26/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation

extension FlickrClient {
	
	// MARK: - Constants
	struct Constants {
		
		// API Key
		static let APIKey = "0b614a623504bee7bb55483c09dccdb5"
		
		// Base URL
		static let BaseURL = "https://api.flickr.com/services/rest/"
	}
	
	// MARK: - Methods
	struct Methods {
		static let Search = "flickr.photos.search"
	}
	
	// MARK: - URL Keys
	struct URLKeys {
		static let APIKey = "api_key"
		static let BoundingBox = "bbox"
		static let Format = "format"
		static let Extras = "extras"
		static let Latitude = "lat"
		static let Longitude = "lon"
		static let Method = "method"
		static let NoJSONCallback = "nojsoncallback"
		static let Page = "page"
		static let PerPage = "per_page"
	}
	
	// MARK: - URL Values
	struct URLValues {
		static let JSONFormat = "json"
		static let URLMediumPhoto = "url_m"
	}
	
	// MARK: - JSON Response Keys
	struct JSONResponseKeys {
		static let Status = "stat"
		static let Code = "code"
		static let Message = "message"
		static let Pages = "pages"
		static let Photos = "photos"
		static let Photo = "photo"
	}
	
	// MARK: - JSON Response Values
	
	struct JSONResponseValues {
		
		static let Fail = "fail"
		static let Ok = "ok"
	}

}
