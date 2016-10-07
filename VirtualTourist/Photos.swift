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
		
		if let imageData = imageData {
			return UIImage(data: imageData)
		}
		
		return nil
	}
	
	// MARK: - Init model
	override init (entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(url: String, pin: Pin, context: NSManagedObjectContext) {
		
		let entity = NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.url = url
		self.pin = pin
		
		print("init from Photos.swift\(url)")
	}
	
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStack.sharedInstance().managedObjectContext
	}
	
}

	

