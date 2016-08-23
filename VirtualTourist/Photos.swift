//
//  Photos.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/19/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photos: NSManagedObject {
	
	var	image: UIImage? {
		
		if let filePath = filePath {
			
			// TO-DO:
			// Check for error here
		
			// Get the file path
		
			let fileName = (filePath as NSString).lastPathComponent
			let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
			let pathArray = [dirPath, fileName]
			let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
		
			return UIImage(contentsOfFile: fileURL.path!)
			
		}
	
		return nil
	
	}

	
}
